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

#include <rules_jni.h>
#ifdef _WIN32
#include <windows.h>
#endif

#include <cstdlib>
#include <iostream>
#include <string>

#include "hello_from_java.h"
#include "tools/cpp/runfiles/runfiles.h"

#define GREETING_NAME "rules_jni"

void clear_env(const char* name) {
#ifdef _WIN32
  SetEnvironmentVariable(name, nullptr);
#else
  unsetenv(name);
#endif
}

int main(int argc, const char** argv) {
  // Override PATH with PATH_OVERRIDE, if set.
  if (getenv("PATH_OVERRIDE") != nullptr) {
    const char* path_override = getenv("PATH_OVERRIDE");
#ifdef _WIN32
    _putenv_s("PATH", path_override);
#else
    setenv("PATH", path_override, 1);
#endif
  }

  // Set up the Bazel runfiles library to get the path to the JAR.
  using ::bazel::tools::cpp::runfiles::Runfiles;
  std::string runfiles_error;
  Runfiles* runfiles = Runfiles::CreateForTest(&runfiles_error);
  if (runfiles == nullptr) {
    runfiles = Runfiles::Create(argv[0], &runfiles_error);
    if (runfiles == nullptr) {
      std::cerr << "Runfiles::CreateForTest and ::Create failed: "
                << runfiles_error << std::endl;
      return EXIT_FAILURE;
    }
  }

  // If we do not want to test finding the Bazel Java toolchain in the runfiles,
  // we have to ensure that runfiles cannot be detected when calling into
  // libjvm. Else, ensure that they are found.
  if (getenv("HERMETIC") != nullptr) {
    rules_jni_init(argv[0]);
  } else {
    clear_env("RUNFILES_MANIFEST_FILE");
    clear_env("RUNFILES_DIR");
    clear_env("TEST_SRCDIR");
    rules_jni_init("does_not_exist");
  }

  std::string greeting = get_java_greeting(*runfiles, GREETING_NAME);
  if (greeting.find(GREETING_NAME) == std::string::npos ||
      greeting.substr(0, 5) != "Good ") {
    std::cerr << "Incorrect greeting: " << greeting << std::endl;
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
