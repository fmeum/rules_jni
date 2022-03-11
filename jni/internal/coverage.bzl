# Copyright 2022 Fabian Meumertzheim
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
load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_toolchain")
load(":common.bzl", "java_identifier", "jni_escaped_identifier")

def _cc_jni_coverage_helper_library_impl(ctx):
    jni_name = jni_escaped_identifier(ctx.attr.library_name)

    c_file = ctx.actions.declare_file(jni_name + ".c")
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = c_file,
        substitutions = {
            "$$NAME$$": jni_name,
        },
    )

    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features + ["coverage"],
    )
    compilation_context, compilation_outputs = cc_common.compile(
        name = jni_name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        srcs = [c_file],
        compilation_contexts = [ctx.attr._jni[CcInfo].compilation_context],
    )
    linking_context, _ = cc_common.create_linking_context_from_compilation_outputs(
        name = jni_name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        alwayslink = True,
        disallow_dynamic_library = True,
    )
    cc_info = CcInfo(
        compilation_context = compilation_context,
        linking_context = linking_context,
    )

    return [cc_info]

cc_jni_coverage_helper_library = rule(
    implementation = _cc_jni_coverage_helper_library_impl,
    attrs = {
        "library_name": attr.string(mandatory = True),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
        "_jni": attr.label(
            default = "//jni",
        ),
        "_template": attr.label(
            default = "//jni/internal/templates:native_library_coverage.tmpl.c",
            allow_single_file = True,
        ),
    },
    fragments = ["cpp"],
    provides = [CcInfo],
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)

def _java_jni_coverage_helper_library_impl(ctx):
    java_name = java_identifier(ctx.attr.library_name)

    java_file = ctx.actions.declare_file(java_name + ".java")
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = java_file,
        substitutions = {
            "$$NAME$$": java_name,
        },
    )

    jar_file = ctx.actions.declare_file(java_name + ".jar")
    java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain)
    java_info = java_common.compile(
        ctx,
        java_toolchain = java_toolchain,
        output = jar_file,
        source_files = [java_file],
    )

    return [java_info]

java_jni_coverage_helper_library = rule(
    implementation = _java_jni_coverage_helper_library_impl,
    attrs = {
        "library_name": attr.string(mandatory = True),
        "_java_toolchain": attr.label(
            default = "@bazel_tools//tools/jdk:current_java_toolchain",
        ),
        "_template": attr.label(
            default = "//jni/internal/templates:native_library_coverage.tmpl.java",
            allow_single_file = True,
        ),
    },
    fragments = ["java"],
    provides = [JavaInfo],
    toolchains = [
        "@bazel_tools//tools/jdk:toolchain_type",
    ],
)
