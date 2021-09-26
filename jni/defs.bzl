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

load("//jni/internal:java_library_with_native.bzl", _java_library_with_native = "java_library_with_native")
load("//jni/internal:java_native_headers.bzl", _java_native_headers = "java_native_headers")
load("//jni/internal:java_native_library.bzl", _java_native_library = "java_native_library")

java_library_with_native = _java_library_with_native
java_native_headers = _java_native_headers
java_native_library = _java_native_library
