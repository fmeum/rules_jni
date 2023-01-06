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

load(":coverage.bzl", "cc_jni_coverage_helper_library", "java_jni_coverage_helper_library")
load(":jni_headers.bzl", "jni_headers")
load(":os_cpu_utils.bzl", "SELECT_TARGET_CPU", "SELECT_TARGET_OS")
load(":transitions.bzl", "multi_platform_transition")

SinglePlatformArtifactInfo = provider(
    fields = ["cpu", "file", "os", "platform"],
)

def _single_platform_artifact_impl(ctx):
    info = ctx.attr.artifact[DefaultInfo]
    files = info.files.to_list()
    if len(files) != 1:
        fail("Expected artifact to consist of a single file, got:\n    " + "\n    ".join(
            [file.short_path for file in files],
        ))
    default_runfiles = info.default_runfiles.files.to_list()
    if len(default_runfiles) != 1:
        fail("Expected no default runfiles on artifact other than the artifact itself, got:\n    " + "\n    ".join(
            [runfile.short_path for runfile in default_runfiles if runfile != files[0]],
        ))
    data_runfiles = info.data_runfiles.files.to_list()
    if len(data_runfiles) != 1:
        fail("Expected no data runfiles on artifact other than the artifact itself, got:\n    " + "\n    ".join(
            [runfile.short_path for runfile in data_runfiles if runfile != files[0]],
        ))
    return [
        SinglePlatformArtifactInfo(
            cpu = ctx.attr.cpu,
            file = files[0],
            os = ctx.attr.os,
            platform = ctx.fragments.platform.platform,
        ),
        coverage_common.instrumented_files_info(
            ctx,
            dependency_attributes = ["artifact"],
        ),
    ]

_single_platform_artifact = rule(
    implementation = _single_platform_artifact_impl,
    attrs = {
        "artifact": attr.label(
            mandatory = True,
        ),
        "cpu": attr.string(
            mandatory = True,
        ),
        "os": attr.string(
            mandatory = True,
        ),
    },
    provides = [SinglePlatformArtifactInfo],
)

_CONFLICTING_PLATFORMS_MESSAGE = """'{identifier}' is produced by multiple platforms:
    {platform1}
    {platform2}
Ensure that every pair of OS and CPU is produced by a single platform."""

def _multi_platform_artifact_impl(ctx):
    files = []
    seen_platforms = {}
    for artifact in ctx.attr.artifact:
        info = artifact[SinglePlatformArtifactInfo]
        identifier = "{original_name}_{os}_{cpu}".format(
            cpu = info.cpu,
            original_name = ctx.attr.original_name,
            os = info.os,
        )
        if (info.cpu, info.os) in seen_platforms:
            fail(_CONFLICTING_PLATFORMS_MESSAGE.format(
                identifier = identifier,
                platform1 = seen_platforms[(info.cpu, info.os)],
                platform2 = info.platform,
            ), attr = "platforms")
        out = ctx.actions.declare_file("{identifier}/{basename}".format(
            basename = info.file.basename,
            identifier = identifier,
        ))
        seen_platforms[(info.cpu, info.os)] = info.platform
        ctx.actions.symlink(
            output = out,
            target_file = info.file,
        )
        files.append(out)

    return [
        DefaultInfo(
            files = depset(files),
        ),
        coverage_common.instrumented_files_info(
            ctx,
            dependency_attributes = ["artifact"],
        ),
    ]

_multi_platform_artifact = rule(
    implementation = _multi_platform_artifact_impl,
    attrs = {
        "artifact": attr.label(
            cfg = multi_platform_transition,
            mandatory = True,
            providers = [SinglePlatformArtifactInfo],
        ),
        "original_name": attr.string(
            mandatory = True,
        ),
        "platforms": attr.label_list(),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
)

def _maven_resource_prefix_if_present():
    # The equivalent for src/*/native of:
    # https://github.com/bazelbuild/bazel/blob/fad21dae0b01d5f9b2274542c89f4c8163c2ff36/src/main/java/com/google/devtools/build/lib/bazel/rules/java/BazelJavaSemantics.java#L652
    segments = native.package_name().split("/")
    for i in range(len(segments) - 2):
        if segments[i] == "src" and segments[i + 2] == "native":
            return "/".join(segments[:i + 3])
    return None

def cc_jni_library(
        name,
        platforms = [],
        **cc_binary_args):
    """A native library that can be loaded by a Java application at runtime.

    Add this target to the `native_libs` of a [`java_jni_library`](#java_jni_library).

    The native libraries are exposed as Java resources, which are placed in a Java package determined from the Bazel
    package of this target according to the
    [Maven standard directory layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html).
    If the library should be included in the `com/example` subdirectory of a deploy JAR, which corresponds to the Java
    package `com.example`, place it under one of the following Bazel package structures:
    * `**/src/*/native/com/example` (preferred)
    * `**/src/*/resources/com/example`
    * `**/src/*/java/com/example`
    * `**/java/com/example`

    *Note:* Building a native library for multiple platforms by setting the `platforms` attribute to a non-empty list of
    platforms requires either remote execution or cross-compilation toolchains for the target platforms. As both require
    a more sophisticated Bazel setup, the following simpler process can be helpful for smaller or open-source projects:

    1. Leave the `platforms` attribute empty or unspecified.
    2. Build the deploy JAR of the Java library or application with all native libraries included separately for each
       target platform, for example using a CI platform.
    3. Manually (outside Bazel) merge the deploy JARs. The `.class` files will be identical and can thus safely be
       replaced, but the resulting JAR will include all versions of the native library and the correct version will be
       loaded at runtime.

    An example of such a CI workflow can be found [here](https://github.com/CodeIntelligenceTesting/jazzer/blob/d1835d6fa2ebfb7b2661cfaaa8acb8bbf42bb486/.github/workflows/release.yml).

    Args:
      name: A unique name for this target.
      platforms: A list of [`platform`s](https://docs.bazel.build/versions/main/be/platform.html#platform) for which
        this native library should be built. If the list is empty (the default), the library is only built for the
        current target platform.
      **cc_binary_args: Any arguments to a
        [`cc_library`](https://docs.bazel.build/versions/main/be/c-cpp.html#cc_library), except for:
        `linkshared` (always `True`), `linkstatic` (always `True`), `data` (runfiles are not supported)
    """
    path, sep, basename = name.rpartition("/")
    macos_library_name = "%s%slib%s.dylib" % (path, sep, basename)
    unix_library_name = "%s%slib%s.so" % (path, sep, basename)
    windows_library_name = "%s%s%s.dll" % (path, sep, basename)

    # Arguments to set on the visible target, not the intermediate cc_binary.
    tags = cc_binary_args.pop("tags", default = None)
    visibility = cc_binary_args.pop("visibility", default = None)

    # Arguments to be set on all targets.
    testonly = cc_binary_args.pop("testonly", default = None)

    java_coverage_helper_name = "%s_java_coverage_helper" % name
    java_jni_coverage_helper_library(
        name = java_coverage_helper_name,
        library_name = basename,
    )

    cc_coverage_helper_name = "%s_cc_coverage_helper" % name
    cc_jni_coverage_helper_library(
        name = cc_coverage_helper_name,
        library_name = basename,
    )

    # Simple concatenation is compatible with select, append is not.
    cc_binary_args.setdefault("deps", [])
    cc_binary_args["deps"] += [
        Label("//jni"),
    ] + select({
        "@fmeum_rules_jni//jni/internal:collect_coverage": [":" + cc_coverage_helper_name],
        "//conditions:default": [],
    })

    native.cc_binary(
        name = macos_library_name,
        linkshared = True,
        linkstatic = True,
        tags = ["manual"],
        testonly = testonly,
        visibility = ["//visibility:private"],
        **cc_binary_args
    )
    native.cc_binary(
        name = unix_library_name,
        linkshared = True,
        linkstatic = True,
        tags = ["manual"],
        testonly = testonly,
        visibility = ["//visibility:private"],
        **cc_binary_args
    )
    native.cc_binary(
        name = windows_library_name,
        linkshared = True,
        linkstatic = True,
        tags = ["manual"],
        testonly = testonly,
        visibility = ["//visibility:private"],
        **cc_binary_args
    )

    single_platform_artifact_name = name + "_single_"
    _single_platform_artifact(
        name = single_platform_artifact_name,
        artifact = select({
            "@platforms//os:macos": macos_library_name,
            "@platforms//os:windows": windows_library_name,
            "//conditions:default": unix_library_name,
        }),
        cpu = SELECT_TARGET_CPU,
        os = SELECT_TARGET_OS,
        tags = ["manual"],
        testonly = testonly,
        visibility = ["//visibility:private"],
    )

    multi_platform_artifact_name = name + "_multi_"
    _multi_platform_artifact(
        name = multi_platform_artifact_name,
        artifact = ":" + single_platform_artifact_name,
        original_name = name,
        platforms = platforms,
        tags = ["manual"],
        testonly = testonly,
        visibility = ["//visibility:private"],
    )

    native.java_library(
        name = name,
        resources = [":" + multi_platform_artifact_name],
        resource_strip_prefix = _maven_resource_prefix_if_present(),
        runtime_deps = select({
            "@fmeum_rules_jni//jni/internal:collect_coverage": [":" + java_coverage_helper_name],
            "//conditions:default": [],
        }),
        tags = tags,
        testonly = testonly,
        visibility = visibility,
    )
