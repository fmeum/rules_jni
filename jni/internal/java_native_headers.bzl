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

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def _java_native_headers_impl(ctx):
    # Giving the include directory a name with a header extension ensures
    # compatibility with Bazel 4.0.0, which only considers the extension and not
    # whether an artifact is a tree artifact (aka a directory) when validating
    # header files (see ad652f12a6).
    include_dir = ctx.actions.declare_directory(ctx.attr.name + ".h")
    native_headers_jar = ctx.attr.lib[JavaInfo].outputs.native_headers

    args = ctx.actions.args()
    args.add("x")
    args.add(native_headers_jar)
    args.add("-d")
    args.add(include_dir.path)
    ctx.actions.run(
        inputs = [native_headers_jar],
        tools = [ctx.executable._zipper],
        outputs = [include_dir],
        executable = ctx.executable._zipper.path,
        arguments = [args],
    )

    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    compilation_context, _ = cc_common.compile(
        name = ctx.attr.name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        public_hdrs = [include_dir],
        quote_includes = [include_dir.path],
    )
    cc_info_with_jni = cc_common.merge_cc_infos(
        direct_cc_infos = [
            CcInfo(compilation_context = compilation_context),
            ctx.attr._jni[CcInfo],
        ],
    )

    return [
        DefaultInfo(files = depset([include_dir])),
        cc_info_with_jni,
    ]

java_native_headers = rule(
    doc = """
Generates the native headers for a `java_library` and exposes it to `cc_*` rules.

For every Java class `com.example.Foo` in the `java_library` target specified by `lib` that contains at least one
function marked with `native` or constant annotated with `@Native`, the include directory exported by this rule will
contain a file `com_example_Foo.h` that provides the C/C++ interface for this class. Consuming `cc_*` rules should have
this rule added to their `deps` and can then access such a header file via:

```c
#include "com_example_Foo.h"
```

This rule also directly exports the JNI header, which can be included via:

```c
#include <jni.h>
```

*Example:*

```starlark
load("@fmeum_rules_jni//jni:defs.bzl", "java_native_headers")

java_library(
    name = "os_utils",
    ...
)

java_native_headers(
    name = "os_utils_hdrs",
    lib = ":os_utils",
)

cc_library(
    name = "os_utils_impl",
    ...
    deps = [":os_utils_hdrs"],
)
```
""",
    implementation = _java_native_headers_impl,
    attrs = {
        "lib": attr.label(
            doc = "The Java library for which native header files should be generated.",
            mandatory = True,
            providers = [JavaInfo],
        ),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        "_jni": attr.label(
            default = Label("//jni"),
        ),
        "_zipper": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@bazel_tools//tools/zip:zipper"),
        ),
    },
    fragments = ["cpp"],
    incompatible_use_toolchain_transition = True,
    provides = [CcInfo],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)
