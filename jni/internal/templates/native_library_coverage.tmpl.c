// Copyright 2022 Fabian Meumertzheim
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

// Disable the LLVM profile runtime's static initializer.
int __llvm_profile_runtime = 0;

void __llvm_profile_initialize_file();
// Using __llvm_profile_dump instead of __llvm_profile_write_file ensures that
// the profile isn't written twice without a warning.
int __llvm_profile_dump();

JNIEXPORT void JNICALL
Java_javax_com_github_fmeum_rules_1jni_gen_$$NAME$$_initCoverageFile() {
  __llvm_profile_initialize_file();
}

JNIEXPORT void JNICALL
Java_javax_com_github_fmeum_rules_1jni_gen_$$NAME$$_writeCoverageFile() {
  __llvm_profile_dump();
}
