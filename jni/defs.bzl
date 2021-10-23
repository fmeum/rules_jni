# Copyright 2021 Fabian Meumertzheim
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//jni/internal:java_jni_library.bzl", _java_jni_library = "java_jni_library")
load("//jni/internal:jni_headers.bzl", _jni_headers = "jni_headers")
load("//jni/internal:cc_jni_library.bzl", _cc_jni_library = "cc_jni_library")

java_jni_library = _java_jni_library
jni_headers = _jni_headers
cc_jni_library = _cc_jni_library
