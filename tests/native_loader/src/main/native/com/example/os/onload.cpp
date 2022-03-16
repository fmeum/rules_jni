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

#include <cstdlib>
#include <iostream>

jint JNI_OnLoad(JavaVM* vm, void* reserved) {
  JNIEnv* env = nullptr;
  jint res = vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_8);
  if (res != JNI_OK) {
    std::cerr << "GetEnv failed" << std::endl;
    exit(1);
  }
  jclass os_utils = env->FindClass("com/example/os/OsUtils");
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    exit(1);
  }
  jfieldID has_jni_on_load_been_called =
      env->GetStaticFieldID(os_utils, "hasJniOnLoadBeenCalled", "Z");
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    exit(1);
  }
  env->SetStaticBooleanField(os_utils, has_jni_on_load_been_called, true);
  if (env->ExceptionCheck()) {
    env->ExceptionDescribe();
    exit(1);
  }
  return JNI_VERSION_1_8;
}
