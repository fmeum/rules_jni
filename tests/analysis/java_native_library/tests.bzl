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

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@fmeum_rules_jni//jni:defs.bzl", "java_native_library")

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
    java_native_library(
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
    java_native_library(
        name = "unsupported_runfiles_native_lib",
        deps = [":unsupported_runfiles_cc_lib"],
        tags = ["manual"],
    )

    unsupported_runfiles_test(
        name = "unsupported_runfiles_test",
        target_under_test = ":unsupported_runfiles_native_lib",
    )

def test_suite(name):
    _test_platform_collision()
    _test_unsupported_runfiles()

    native.test_suite(
        name = name,
        tests = [
            ":platform_collision_test",
            ":unsupported_runfiles_test",
        ],
    )
