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

#include "hello_from_java.h"

#include <jni.h>

#include <fstream>
#include <iostream>
#include <string>

#include "tools/cpp/runfiles/runfiles.h"

#define HELLO_FROM_JAVA_JAR_PATH \
  "fmeum_rules_jni_tests/libjvm_stub/HelloFromJava_deploy.jar"
#define HELLO_FROM_JAVA_JAR_PATH_BZLMOD \
  "_main/libjvm_stub/HelloFromJava_deploy.jar"

using ::bazel::tools::cpp::runfiles::Runfiles;

std::string get_java_greeting(const Runfiles& runfiles,
                              const std::string& name) {
  // Configure the JVM by adding the test JAR to the classpath and passing a
  // message via a property.
  std::string jar_path = runfiles.Rlocation(HELLO_FROM_JAVA_JAR_PATH);
  if (!std::ifstream(jar_path).good()) {
    jar_path = runfiles.Rlocation(HELLO_FROM_JAVA_JAR_PATH_BZLMOD);
  }
  std::string class_path = "-Djava.class.path=" + jar_path;
  JavaVM* jvm = nullptr;
  JNIEnv* env = nullptr;
  JavaVMInitArgs vm_args;
  JavaVMOption options[] = {
      JavaVMOption{const_cast<char*>(class_path.c_str())},
  };
  vm_args.version = JNI_VERSION_1_8;
  vm_args.nOptions = 1;
  vm_args.options = options;
  vm_args.ignoreUnrecognized = false;
  jint ret = JNI_GetDefaultJavaVMInitArgs(&vm_args);
  if (ret != JNI_OK) {
    std::cerr << "Failed to get default JVM init args" << std::endl;
    return "";
  }

  // Create a JVM with the given options.
  ret = JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
  if (ret != JNI_OK || env == nullptr) {
    std::cerr << "Failed to create JVM" << std::endl;
    return "";
  }

  // Verify that JNI_GetCreatedJavaVMs returns the created VM.
  JavaVM* created_jvm = nullptr;
  jsize num_vms = 0;
  ret = JNI_GetCreatedJavaVMs(&created_jvm, 1, &num_vms);
  if (ret != JNI_OK || num_vms != 1 || created_jvm != jvm) {
    std::cerr << "Failed to get created Java VM" << std::endl;
    return "";
  }

  // Call a Java method that returns a String.
  jclass hello_from_java_class = env->FindClass("com/example/HelloFromJava");
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    return "";
  }
  jmethodID hello_from_java_method =
      env->GetStaticMethodID(hello_from_java_class, "helloFromJava",
                             "(Ljava/lang/String;)Ljava/lang/String;");
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    return "";
  }
  jstring name_jni = env->NewStringUTF(name.c_str());
  auto hello_from_java_jni =
      reinterpret_cast<jstring>(env->CallStaticObjectMethod(
          hello_from_java_class, hello_from_java_method, name_jni));
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    return "";
  }
  env->DeleteLocalRef(name_jni);

  const char* hello_from_java_cstr =
      env->GetStringUTFChars(hello_from_java_jni, nullptr);
  std::string hello_from_java(hello_from_java_cstr);
  env->ReleaseStringUTFChars(hello_from_java_jni, hello_from_java_cstr);

  // Verify that the JVM was destroyed correctly.
  ret = jvm->DestroyJavaVM();
  if (ret != JNI_OK) {
    std::cerr << "Failed to destroy JVM" << std::endl;
    return "";
  }

  return hello_from_java;
}
