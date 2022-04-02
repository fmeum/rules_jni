// Copyright 2021 Fabian Meumertzheim
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <algorithm>
#include <cstdlib>
#include <fstream>
#include <string>
#include <utility>
#include <vector>

#include "jni/tools/libjvm_stub/current_java_runtime.h"
#include "rules_jni_internal.h"
#include "tools/cpp/runfiles/runfiles.h"

#define JACOCO_MAIN_CLASS "JACOCO_MAIN_CLASS"
#define JAVA_TOOL_OPTIONS "JAVA_TOOL_OPTIONS"
#define MSG_PREFIX "[rules_jni]: "
#define RULES_JNI_COVERAGE_AGENT_JAR "RULES_JNI_COVERAGE_AGENT_JAR"

using ::bazel::tools::cpp::runfiles::Runfiles;

static const char* rules_jni_arg0 = "";

static std::unique_ptr<Runfiles> get_runfiles() {
  Runfiles* runfiles = Runfiles::CreateForTest();
  if (runfiles != nullptr) {
    return std::unique_ptr<Runfiles>(runfiles);
  }
  return std::unique_ptr<Runfiles>(Runfiles::Create(rules_jni_arg0));
}

static void set_env(const std::string& key, const std::string& value) {
#ifdef _WIN32
  _putenv_s(key.c_str(), value.c_str());
#else
  setenv(key.c_str(), value.c_str(), 1);
#endif
}

void rules_jni_init(const char* argv0) {
  rules_jni_arg0 = argv0;
  auto runfiles = get_runfiles();
  if (runfiles != nullptr) {
    std::vector<std::pair<std::string, std::string>> envvars =
        runfiles->EnvVars();
    // Setting the runfiles variables for the current process is the only way
    // to get them to the Java runfiles library.
    for (const std::pair<std::string, std::string>& envvar : envvars) {
      set_env(envvar.first, envvar.second);
    }
  }
  if (RULES_JNI_COLLECT_COVERAGE) {
    std::string coverage_agent;
    if (runfiles != nullptr) {
      coverage_agent = runfiles->Rlocation(
          "fmeum_rules_jni/jni/tools/libjvm_stub/coverage/"
          "CoverageAgent_deploy.jar");
    } else if (getenv(RULES_JNI_COVERAGE_AGENT_JAR) != nullptr) {
      // This should only every happen in tests.
      coverage_agent = getenv(RULES_JNI_COVERAGE_AGENT_JAR);
    }
    if (coverage_agent.empty()) {
      fprintf(stderr, MSG_PREFIX "failed to find CoverageAgent");
      exit(EXIT_FAILURE);
    }
    // The JVM prepends JAVA_TOOL_OPTIONS to the options passed to the
    // CreateJavaVM call. By prepending our agent to the variable, we ensure
    // that the coverage setup code runs as early as possible. The agent is
    // essentially just a startup hook and does not perform any logic other
    // than executing Bazel's JacocoCoverageRunner's main function.
    // Note: The value of JAVA_TOOL_OPTIONS may be changed by the program
    // between the call to rules_jni_init and the call to CreateJavaVM. If it
    // is overwritten, this is arguably a bug in the program and if it is not,
    // coverage will still be collected. This seems better than the
    // alternative of modifying the environment right before the stub makes
    // the actual call to CreateJavaVM as setenv on Linux is inherently unsafe
    // to call after the very early, synchronous setup stage of a program.
    std::string java_agent_option = "'-javaagent:" + coverage_agent + "'";
    const char* java_tool_options = getenv(JAVA_TOOL_OPTIONS);
    if (java_tool_options == nullptr) {
      set_env(JAVA_TOOL_OPTIONS, java_agent_option);
    } else {
      set_env(JAVA_TOOL_OPTIONS, java_agent_option + " " + java_tool_options);
    }
    // We have to ensure that JacocoCoverageRunner#getMainClass always returns
    // our empty main method as CreateJavaVM is not expected to actually run
    // any main classes. There are two cases:
    // 1. Our agent deploy jar is the only jar on the classpath. In this case,
    // the insideDeployJar parameter may be true, but since we do not define
    // the Coverage-Main-Class attribute in the agent's manifest, the function
    // will return the value of JACOCO_MAIN_CLASS set below.
    // 2. Our agent is not the only jar on the classpath. In this case,
    // metadataFiles in JacocoCoverageRunner#main will have length at least 2
    // and thus insideDeployJar will always be false.
    set_env(JACOCO_MAIN_CLASS,
            "com.github.fmeum.rules_jni.libjvm_stub.CoverageAgent");
  }
}

static bool ends_with(const std::string& str, const std::string& suffix) {
  if (str.size() < suffix.size()) {
    return false;
  }
  return str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

static std::string get_bazel_java_home() {
  auto runfiles = get_runfiles();
  if (runfiles == nullptr) {
    return "";
  }
  std::string java_executable_path =
      runfiles->Rlocation(RULES_JNI_JAVA_EXECUTABLE_RLOCATION);
  if (java_executable_path.empty()) {
    return "";
  }
  std::ifstream java_executable(java_executable_path);
  if (!java_executable.good()) {
    // This case can happen when the binary using libjvm_stub is itself launched
    // from another, top-level binary that does not set the variables used for
    // runfiles discovery. If the top-level binary uses a runfiles manifest to
    // find the current binary, it will execute it using a path that points into
    // the Bazel cache. Since the contents of the cache are not hermetic, an
    // adjacent out-of-date .runfiles directory or MANIFEST may exist as a left-
    // over from a previous direct run of the current binary. Since there is no
    // way to detect this scenario, fall back to a system-provided JDK but print
    // a warning.
    fprintf(stderr,
            MSG_PREFIX
            "falling back to system JDK, java executable in "
            "runfiles not found at:\n%s\n",
            java_executable_path.c_str());
    return "";
  }
  if (ends_with(java_executable_path, "/bin/java")) {
    return java_executable_path.substr(0, java_executable_path.size() - 9);
  }
  // The only non-failure case left is Windows, so ensure we use the correct
  // path separator for it.
  std::replace(java_executable_path.begin(), java_executable_path.end(), '/',
               '\\');
  if (ends_with(java_executable_path, "\\bin\\java.exe")) {
    return java_executable_path.substr(0, java_executable_path.size() - 13);
  }
  fprintf(stderr,
          MSG_PREFIX "java executable in runfiles has unexpected suffix:\n%s\n",
          java_executable_path.c_str());
  exit(EXIT_FAILURE);
}

static std::string bazel_java_home;

extern "C" const char* rules_jni_internal_get_bazel_java_home() {
  bazel_java_home = get_bazel_java_home();
  if (!bazel_java_home.empty()) {
    return bazel_java_home.c_str();
  } else {
    return nullptr;
  }
}
