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
#include <fstream>
#include <iostream>
#include <string>

#include "jni/tools/libjvm_stub/current_java_runtime.h"
#include "rules_jni_internal.h"
#include "tools/cpp/runfiles/runfiles.h"

using ::bazel::tools::cpp::runfiles::Runfiles;

static const char* rules_jni_arg0 = "";

void rules_jni_init(const char* argv0) { rules_jni_arg0 = argv0; }

static Runfiles* get_runfiles() {
  Runfiles* runfiles = Runfiles::CreateForTest();
  if (runfiles != nullptr) {
    return runfiles;
  }
  return Runfiles::Create(rules_jni_arg0);
}

static bool ends_with(const std::string& str, const std::string& suffix) {
  if (str.size() < suffix.size()) {
    return false;
  }
  return str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

static std::string get_bazel_java_home() {
  Runfiles* runfiles = get_runfiles();
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
    printf("rules_jni: Bazel-provided java executable does not exist at: %s\n",
           java_executable_path.c_str());
    exit(EXIT_FAILURE);
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
  printf(
      "rules_jni: Bazel-provided java executable path has unexpected suffix: "
      "%s\n",
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
