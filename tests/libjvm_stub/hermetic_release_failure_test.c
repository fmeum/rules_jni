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

#include <jni.h>
#include <rules_jni.h>
#include <stdlib.h>

static int exit_code = EXIT_SUCCESS;

void return_exit_code(void) { _Exit(exit_code); }

int main(int argc, const char** argv) {
  // No-op with //jni:libjvm_release.
  rules_jni_init(argv[0]);
  // Override PATH with PATH_OVERRIDE, if set.
  if (getenv("PATH_OVERRIDE") != NULL) {
    const char* path_override = getenv("PATH_OVERRIDE");
#ifdef _WIN32
    _putenv_s("PATH", path_override);
#else
    setenv("PATH", path_override, 1);
#endif
  }
  JavaVMInitArgs vm_args;
  vm_args.version = JNI_VERSION_1_8;

  atexit(return_exit_code);
  // We expect this call to fail and call exit: PATH and JAVA_HOME are not
  // available and the release version of libjvm_stub is used, which means that
  // the current Bazel Java runtime also cannot be found.
  JNI_GetDefaultJavaVMInitArgs(&vm_args);
  // Should not be reached.
  exit_code = EXIT_FAILURE;
  return exit_code;
}
