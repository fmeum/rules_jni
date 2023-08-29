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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def jdk_deps():
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_jni_h",
        downloaded_file_path = "jni.h",
        sha256 = "99e64ebbe749e6df284f852f11b3c73f6ea97baf15120428f40f887fe0616e61",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-22%2B12/src/java.base/share/native/include/jni.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_unix_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "88cb5c33e306900dd35a78d5a439087123b8e91b0986bb5acb42cc9bd2fcc42e",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-22%2B12/src/java.base/unix/native/include/jni_md.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_windows_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "3cacac1e4802ec246ea7c0c6772d4ac40c9f7255d4df095cfffe601137689771",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-22%2B12/src/java.base/windows/native/include/jni_md.h"],
    )

def rules_jni_dependencies():
    """Adds all external repositories required for rules_jni.

This should be called from a `WORKSPACE` file after the declaration of `fmeum_rules_jni` itself.

Currently, rules_jni depends on:

* [bazel_skylib](https://github.com/bazelbuild/bazel-skylib)
* [platforms](https://github.com/bazelbuild/platforms)
* individual files of the [OpenJDK](https://github.com/openjdk/jdk)

"""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "platforms",
        sha256 = "3a561c99e7bdbe9173aa653fd579fe849f1d8d67395780ab4770b1f381431d51",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.7/platforms-0.0.7.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.7/platforms-0.0.7.tar.gz",
        ],
    )

    # https://github.com/bazelbuild/platforms/issues/66
    maybe(
        http_archive,
        name = "rules_license",
        sha256 = "4531deccb913639c30e5c7512a054d5d875698daeb75d8cf90f284375fe7c360",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_license/releases/download/0.0.7/rules_license-0.0.7.tar.gz",
            "https://github.com/bazelbuild/rules_license/releases/download/0.0.7/rules_license-0.0.7.tar.gz",
        ],
    )
    jdk_deps()
