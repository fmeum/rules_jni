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
        http_file,
        name = "com_github_openjdk_jdk_jni_h",
        downloaded_file_path = "jni.h",
        sha256 = "91f19e0a31a518631ba1ba201238a3af07af754fe541ff1f2a6b62d6358914e7",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-19%2B36/src/java.base/share/native/include/jni.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_unix_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "88cb5c33e306900dd35a78d5a439087123b8e91b0986bb5acb42cc9bd2fcc42e",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-19%2B36/src/java.base/unix/native/include/jni_md.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_windows_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "dbf96659c4c840b15ef40237db0c65657eca7a70904225fc984deb38999df515",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-19%2B36/src/java.base/windows/native/include/jni_md.h"],
    )
    maybe(
        http_archive,
        name = "platforms",
        sha256 = "379113459b0feaf6bfbb584a91874c065078aa673222846ac765f86661c27407",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.5/platforms-0.0.5.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.5/platforms-0.0.5.tar.gz",
        ],
    )
