/*
 * Copyright 2021 Fabian Meumertzheim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cstdlib>

#include "com_example_os_OsUtils.h"

jint Java_com_example_os_OsUtils_setenv(JNIEnv* env, jclass clazz, jstring name,
                                        jstring value) {
  const char* name_cstr = env->GetStringUTFChars(name, nullptr);
  const char* value_cstr = env->GetStringUTFChars(value, nullptr);
  int res = _putenv_s(name_cstr, value_cstr);
  env->ReleaseStringUTFChars(name, name_cstr);
  env->ReleaseStringUTFChars(value, value_cstr);
  return res;
}
