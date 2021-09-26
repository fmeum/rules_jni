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

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def rlocation_path(ctx, short_path):
    return paths.normalize(ctx.workspace_name + "/" + short_path)

CURRENT_JAVA_RUNTIME_HEADER_TEMPLATE = """#ifndef RULES_JNI_CURRENT_JAVA_RUNTIME_H
#define RULES_JNI_CURRENT_JAVA_RUNTIME_H
#define RULES_JNI_JAVA_EXECUTABLE_RLOCATION "{}"
#endif
"""

def _current_java_runtime_impl(ctx):
    java_runtime_info = ctx.attr._current_java_runtime[java_common.JavaRuntimeInfo]
    java_rlocation_path = rlocation_path(ctx, java_runtime_info.java_executable_runfiles_path)

    header = ctx.actions.declare_file(ctx.attr.name + ".h")
    ctx.actions.write(header, CURRENT_JAVA_RUNTIME_HEADER_TEMPLATE.format(java_rlocation_path))

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
        public_hdrs = [header],
    )

    return [
        DefaultInfo(
            runfiles = ctx.attr._current_java_runtime[DefaultInfo].default_runfiles,
        ),
        CcInfo(
            compilation_context = compilation_context,
        ),
    ]

current_java_runtime = rule(
    implementation = _current_java_runtime_impl,
    attrs = {
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
        "_current_java_runtime": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        ),
    },
    fragments = ["cpp"],
    incompatible_use_toolchain_transition = True,
    provides = [CcInfo],
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)
