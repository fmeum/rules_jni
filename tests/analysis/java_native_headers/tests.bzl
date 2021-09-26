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
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//jni:defs.bzl", "java_native_headers")

def _provider_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    target_name = target_under_test.label.name
    compilation_context = target_under_test[CcInfo].compilation_context

    asserts.set_equals(
        env,
        expected = sets.make(["jni.h", "jni_md.h", target_name]),
        actual = sets.make([file.basename for file in compilation_context.headers.to_list()]),
    )

    asserts.equals(
        env,
        expected = [],
        actual = compilation_context.includes.to_list(),
    )

    quote_include_basenames = [path.split("/")[-1] for path in compilation_context.quote_includes.to_list()]
    asserts.true(env, target_name in quote_include_basenames)
    asserts.false(env, "jni.h" in quote_include_basenames)
    asserts.false(env, "jni_md.h" in quote_include_basenames)

    system_include_paths = [path for path in compilation_context.system_includes.to_list()]
    asserts.false(env, "." in system_include_paths)
    asserts.true(env, "jni/internal" in system_include_paths)

    asserts.equals(
        env,
        expected = [target_name],
        actual = [file.basename for file in target_under_test[DefaultInfo].files.to_list()],
    )

    return analysistest.end(env)

provider_test = analysistest.make(_provider_test_impl)

def _test_provider():
    native.java_library(
        name = "provider_java_lib",
        tags = ["manual"],
    )
    java_native_headers(
        name = "provider_headers",
        lib = ":provider_java_lib",
        tags = ["manual"],
    )

    provider_test(
        name = "provider_test",
        target_under_test = ":provider_headers",
    )

def test_suite(name):
    _test_provider()

    native.test_suite(
        name = name,
        tests = [
            ":provider_test",
        ],
    )
