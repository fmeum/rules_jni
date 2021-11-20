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
#ifdef _WIN32
#include <windows.h>
#endif

#include <codecvt>
#include <cstdlib>
#include <iostream>
#include <locale>

#include "tools/cpp/runfiles/runfiles.h"

#define HELLO_FROM_JAVA_JAR_PATH "libjvm_stub/HelloFromJava_deploy.jar"
#define HELLO_FROM_JAVA_MSG "Hello_from_Java!"
#ifdef _WIN32
#define CLASSPATH_SEPARATOR ";"
#else
#define CLASSPATH_SEPARATOR ":"
#endif

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

  // Configure the JVM by adding the test JAR to the classpath and passing a
  // message via a property.
  // TODO: Since the name of the current repository differs when the tests are
  //       loaded as a module extension, we pass in multiple paths of which only
  //       ever one will be valid. Use rules_runfiles instead once it becomes
  //       available as a Bazel module.
  std::string jar_path_workspace =
      runfiles->Rlocation("fmeum_rules_jni_tests/" HELLO_FROM_JAVA_JAR_PATH);
  std::string jar_path_module = runfiles->Rlocation(
      ".install_dev_dependencies.fmeum_rules_jni_"
      "tests/" HELLO_FROM_JAVA_JAR_PATH);
  std::string class_path = "-Djava.class.path=" + jar_path_workspace +
                           CLASSPATH_SEPARATOR + jar_path_module;
  JavaVM* jvm = nullptr;
  JNIEnv* env = nullptr;
  JavaVMInitArgs vm_args;
  JavaVMOption options[] = {
      JavaVMOption{const_cast<char*>(class_path.c_str())},
      JavaVMOption{const_cast<char*>("-Dmsg.hello=" HELLO_FROM_JAVA_MSG)},
      JavaVMOption{const_cast<char*>("-Djdk.attach.allowAttachSelf=true")},
  };
  vm_args.version = JNI_VERSION_1_8;
  vm_args.nOptions = 3;
  vm_args.options = options;
  vm_args.ignoreUnrecognized = false;
  jint ret = JNI_GetDefaultJavaVMInitArgs(&vm_args);
  if (ret != JNI_OK) {
    std::cerr << "Failed to get default JVM init args" << std::endl;
    return EXIT_FAILURE;
  }

  // Create a JVM with the given options.
  ret = JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
  if (ret != JNI_OK || env == nullptr) {
    std::cerr << "Failed to create JVM" << std::endl;
    return EXIT_FAILURE;
  }

  // Verify that JNI_GetCreatedJavaVMs returns the created VM.
  JavaVM* created_jvm = nullptr;
  jsize num_vms = 0;
  ret = JNI_GetCreatedJavaVMs(&created_jvm, 1, &num_vms);
  if (ret != JNI_OK || num_vms != 1 || created_jvm != jvm) {
    std::cerr << "Failed to get created Java VM" << std::endl;
    return EXIT_FAILURE;
  }

  // Call a Java method that returns a String.
  jclass hello_from_java_class = env->FindClass("com/example/HelloFromJava");
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    return EXIT_FAILURE;
  }
  jmethodID hello_from_java_method = env->GetStaticMethodID(
      hello_from_java_class, "helloFromJava", "()Ljava/lang/String;");
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    return EXIT_FAILURE;
  }
  auto hello_from_java_jni =
      reinterpret_cast<jstring>(env->CallStaticObjectMethod(
          hello_from_java_class, hello_from_java_method));
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    return EXIT_FAILURE;
  }

  // Convert the returned string from UTF-16 to UTF-8 and verify it.
  static_assert(sizeof(jchar) == sizeof(char16_t),
                "jchar cannot be converted to char16_t");
  const jchar* hello_from_java_cstr =
      env->GetStringChars(hello_from_java_jni, nullptr);
  std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t>
      utf16_to_utf8;
  std::string hello_from_java = utf16_to_utf8.to_bytes(
      reinterpret_cast<const char16_t*>(hello_from_java_cstr));
  env->ReleaseStringChars(hello_from_java_jni, hello_from_java_cstr);
  if (hello_from_java != HELLO_FROM_JAVA_MSG) {
    std::cerr << "helloFromJava() returned unexpected value: "
              << hello_from_java << std::endl;
    return EXIT_FAILURE;
  }

  // Verify that the JVM was destroyed correctly.
  ret = jvm->DestroyJavaVM();
  if (ret != JNI_OK) {
    std::cerr << "Failed to destroy JVM" << std::endl;
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
