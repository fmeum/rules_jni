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

#include <stddef.h>

#include "rules_jni_internal.h"

const char* rules_jni_internal_get_bazel_java_home(void) { return NULL; }

void rules_jni_init(const char* argv0) {}

jint rules_jni_create_java_vm_for_coverage(
    jint (*create_java_vm)(JavaVM**, void**, void*), JavaVM** pvm, void** penv,
    void* args) {
  return create_java_vm(pvm, penv, args);
}
