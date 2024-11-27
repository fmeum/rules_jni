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

load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@fmeum_rules_jni//jni:defs.bzl", "cc_jni_library")
load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")

MULTI_PLATFORM_TEST_NATIVE_LIBRARY_NAME = "multi_platform_native_lib"

def _trim_prefix(str, prefix):
    if str.startswith(prefix):
        return str[len(prefix):]
    return str

def _multi_platform_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    files = target_under_test[DefaultInfo].files

    repo_name = ctx.label.workspace_name
    actual_paths = sets.make([_trim_prefix(file.short_path, "../%s/" % repo_name) for file in files.to_list()])
    lib_prefixes = {
        "linux": "lib",
        "macos": "lib",
        "windows": "",
    }
    lib_extensions = {
        "linux": "so",
        "macos": "dylib",
        "windows": "dll",
    }
    expected_paths = sets.make([
        "{package}/{name}_{os}_x86_64/{lib_prefix}{name}.{lib_extension}".format(
            package = ctx.label.package,
            name = MULTI_PLATFORM_TEST_NATIVE_LIBRARY_NAME,
            os = os,
            lib_prefix = lib_prefixes[os],
            lib_extension = lib_extensions[os],
        )
        for os in ["linux", "macos", "windows"]
    ])
    asserts.set_equals(env, expected_paths, actual_paths)

    actions = analysistest.target_actions(env)
    coverage_mnemonics = []
    if ctx.coverage_instrumented(target_under_test):
        coverage_mnemonics = ["BaselineCoverage"]
    asserts.equals(env, 3 * ["Symlink"] + coverage_mnemonics, [action.mnemonic for action in actions])

    # Verify that all artifacts were built in different configurations.
    file_roots = [file.root.path for action in actions for file in action.inputs.to_list()]
    asserts.equals(env, 3, len(file_roots))
    asserts.equals(env, 3, sets.length(sets.make(file_roots)))

    return analysistest.end(env)

multi_platform_test = analysistest.make(
    _multi_platform_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ",".join(
            [
                str(Label("//analysis/cc_jni_library:fake_%s_toolchain" % os))
                for os in ["linux", "macos", "windows"]
            ],
        ),
    },
)

def _get_host_constraint_value(constraint_setting):
    constraint_prefix = "@platforms//%s:" % constraint_setting
    for constraint in HOST_CONSTRAINTS:
        if constraint.startswith(constraint_prefix):
            return constraint[len(constraint_prefix):]
    fail("Failed to find value for %s in HOST_CONSTRAINTS: %s" % (constraint_setting, HOST_CONSTRAINTS))

def _get_host_legacy_cpu():
    cpu = _get_host_constraint_value("cpu")
    os = _get_host_constraint_value("os")

    # Indirectly test for Bazel 7 via:
    # https://github.com/bazelbuild/bazel/commit/31fd464af77f084049386af02dbcc5189c745892
    is_bazel_7_or_higher = attr.string() == attr.string()
    if os == "osx" and cpu == "aarch64":
        return "darwin_arm64"
    if cpu != "x86_64":
        fail("This test requires the host CPU to be x86_64 or darwin_arm64, got: %s" % cpu)
    if os == "linux":
        return "k8"
    elif os == "osx":
        #if is_bazel_7_or_higher:
        return "darwin_x86_64"
        # else:
           # return "darwin"
    elif os == "windows":
        return "x64_windows"
    else:
        fail("This test requires the host OS to be linux, macos or windows, got: %s" % os)

def _test_multi_platform():
    local_config_cc_toolchain_label = "@local_config_cc//:cc-compiler-%s" % _get_host_legacy_cpu()

    native.platform(
        name = "multi_platform_linux",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "multi_platform_macos",
        constraint_values = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "multi_platform_windows",
        constraint_values = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    )

    # These fake toolchains are simply the host autodetected cc toolchain, but
    # marked as supporting the given target architecture.
    native.toolchain(
        name = "fake_linux_toolchain",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        toolchain = local_config_cc_toolchain_label,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
    native.toolchain(
        name = "fake_macos_toolchain",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        toolchain = local_config_cc_toolchain_label,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
    native.toolchain(
        name = "fake_windows_toolchain",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        toolchain = local_config_cc_toolchain_label,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
    cc_jni_library(
        name = MULTI_PLATFORM_TEST_NATIVE_LIBRARY_NAME,
        platforms = [
            ":multi_platform_linux",
            ":multi_platform_macos",
            ":multi_platform_windows",
        ],
        tags = ["manual"],
    )

    multi_platform_test(
        name = "multi_platform_test",
        # Test the providers of the _multi_platform_artifact rule since the
        # contents of publicly visible java_library wrapping the artifacts
        # cannot be inspected during analysis time.
        target_under_test = ":%s_multi_" % MULTI_PLATFORM_TEST_NATIVE_LIBRARY_NAME,
        # Since Bazel 6.3.0, the cc_jni_library output is part of the
        # `metadata_files` of its `InstrumentedFilesInfo` provider and thus
        # requested for execution by the coverage command. However, since it
        # uses a fake toolchain, it can't be built.
        tags = ["no-coverage"],
    )

def _platform_collision_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ":platform_collision_platform_1")
    asserts.expect_failure(env, ":platform_collision_platform_2")
    return analysistest.end(env)

platform_collision_test = analysistest.make(
    _platform_collision_test_impl,
    expect_failure = True,
)

def _test_platform_collision():
    native.platform(
        name = "platform_collision_platform_1_linux",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "platform_collision_platform_2_linux",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "platform_collision_platform_1_macos",
        constraint_values = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "platform_collision_platform_2_macos",
        constraint_values = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "platform_collision_platform_1_windows",
        constraint_values = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    )
    native.platform(
        name = "platform_collision_platform_2_windows",
        constraint_values = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    )
    cc_jni_library(
        name = "platform_collision_native_lib",
        platforms = select({
            "@platforms//os:linux": [
                ":platform_collision_platform_1_linux",
                ":platform_collision_platform_2_linux",
            ],
            "@platforms//os:macos": [
                ":platform_collision_platform_1_macos",
                ":platform_collision_platform_2_macos",
            ],
            "@platforms//os:windows": [
                ":platform_collision_platform_1_windows",
                ":platform_collision_platform_2_windows",
            ],
        }),
        tags = ["manual"],
    )

    platform_collision_test(
        name = "platform_collision_test",
        target_under_test = ":platform_collision_native_lib",
    )

def _unsupported_runfiles_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "runfiles")
    asserts.expect_failure(env, "/tests.bzl")
    return analysistest.end(env)

unsupported_runfiles_test = analysistest.make(
    _unsupported_runfiles_test_impl,
    expect_failure = True,
)

def _test_unsupported_runfiles():
    native.cc_library(
        name = "unsupported_runfiles_cc_lib",
        data = [":tests.bzl"],
    )
    cc_jni_library(
        name = "unsupported_runfiles_native_lib",
        deps = [":unsupported_runfiles_cc_lib"],
        tags = ["manual"],
    )

    unsupported_runfiles_test(
        name = "unsupported_runfiles_test",
        target_under_test = ":unsupported_runfiles_native_lib",
    )

def test_suite(name):
    _test_multi_platform()
    _test_platform_collision()
    _test_unsupported_runfiles()

    native.test_suite(
        name = name,
        tests = [
            ":multi_platform_test",
            ":platform_collision_test",
            ":unsupported_runfiles_test",
        ],
    )
