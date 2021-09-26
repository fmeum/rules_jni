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

load(":common.bzl", "merge_java_infos", "original_java_library_name")

def java_library_with_native(
        name,
        visibility = None,
        native_libs = None,
        tags = None,
        **java_library_args):
    original_name = original_java_library_name(name)

    # Simple concatenation is compatible with select, append is not.
    java_library_args.setdefault("deps", [])
    java_library_args["deps"] += ["@fmeum_rules_jni//jni/tools/jni_loader"]

    java_library_args.setdefault("tags", [])
    if tags:
        java_library_args["tags"] += tags
    if "manual" not in java_library_args["tags"]:
        java_library_args["tags"].append("manual")
    native.java_library(
        name = original_name,
        visibility = visibility,
        **java_library_args
    )

    merge_java_infos(
        name = name,
        libs = [
            ":" + original_name,
        ] + (native_libs if native_libs else []),
        tags = tags,
        visibility = visibility,
    )
