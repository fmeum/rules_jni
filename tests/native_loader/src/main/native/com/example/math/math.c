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

#include "com_example_math_NativeMath.h"

// 'JNIEnv*' and 'jclass' params are implicit and must be included.
jint Java_com_example_math_NativeMath_increment(JNIEnv* env, jclass clazz,
                                                jint arg1) {
  return Java_com_example_math_NativeMath_add(
      env, clazz, arg1, com_example_math_NativeMath_incrementBy);
}

jint Java_com_example_math_NativeMath_add(JNIEnv* env, jclass clazz, jint arg1,
                                          jint arg2) {
  return arg1 + arg2;
}
