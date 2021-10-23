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

load(":common.bzl", "merge_java_infos")
load(":jni_headers.bzl", "jni_headers")

def java_jni_library(
        name,
        native_libs = None,
        tags = None,
        visibility = None,
        **java_library_args):
    original_name = "%s_remove_this_part_" % name
    headers_name = "%s.hdrs" % name

    # Simple concatenation is compatible with select, append is not.
    java_library_args.setdefault("deps", [])
    java_library_args["deps"] += ["@fmeum_rules_jni//jni/tools/native_loader"]

    native.java_library(
        name = original_name,
        tags = ["manual"],
        visibility = ["//visibility:private"],
        **java_library_args
    )

    jni_headers(
        name = headers_name,
        lib = ":" + original_name,
        tags = ["manual"],
        visibility = visibility,
    )

    merge_java_infos(
        name = name,
        libs = [
            ":" + original_name,
        ] + (native_libs if native_libs else []),
        tags = tags,
        visibility = visibility,
    )
