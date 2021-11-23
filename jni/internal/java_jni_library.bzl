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
        native_libs = [],
        **java_library_args):
    """A Java library that bundles one or more native libraries created with [`cc_jni_library`](#cc_jni_library).

    To load a native library referenced in the `native_libs` argument, use the static methods of the
    [`RulesJni`](https://fmeum.github.io/rules_jni_javadocs/com/github/fmeum/rules_jni/RulesJni.html) class, which is
    accessible for `srcs` of this target due to an implicit dependency on
    [`@fmeum_rules_jni//jni/tools/native_loader`](targets.md#native_loader). These methods automatically choose the
    correct version of the library for the current OS and CPU architecture, if available.

    The native libraries referenced in the `native_libs` argument are added as resources and are thus included in the
    deploy JARs of any [`java_binary`](https://docs.bazel.build/versions/main/be/java.html#java_binary) depending on
    this target.

    ### Implicit output targets

    - `<name>.hdrs`: The auto-generated JNI headers for this library.

      This target can be added to the `deps` of a
      [`cc_library`](https://docs.bazel.build/versions/main/be/c-cpp.html#cc_library) or
      [`cc_jni_library`](#cc_jni_library). See [`jni_headers`](#jni_headers) for a more detailed description of the
      underlying rule.

    Args:
      name: A unique name for this target.
      native_libs: A list of [`cc_jni_library`](#cc_jni_library) targets to include in this Java library.
      **java_library_args: Any arguments to a
        [`java_library`](https://docs.bazel.build/versions/main/be/java.html#java_library).
    """
    original_name = "%s_remove_this_part_" % name
    headers_name = "%s.hdrs" % name

    # Arguments to set on the visible target, not the intermediate java_library.
    tags = java_library_args.pop("tags", default = None)
    visibility = java_library_args.pop("visibility", default = None)

    # Simple concatenation is compatible with select, append is not.
    java_library_args.setdefault("deps", [])
    java_library_args["deps"] += [Label("//jni/tools/native_loader")]

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
        ] + native_libs,
        tags = tags,
        visibility = visibility,
    )
