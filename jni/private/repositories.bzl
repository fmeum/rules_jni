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

visibility("//jni/...")

def jdk_deps():
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_jni_h",
        downloaded_file_path = "jni.h",
        sha256 = "99e64ebbe749e6df284f852f11b3c73f6ea97baf15120428f40f887fe0616e61",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-23%2B20/src/java.base/share/native/include/jni.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_unix_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "88cb5c33e306900dd35a78d5a439087123b8e91b0986bb5acb42cc9bd2fcc42e",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-23%2B20/src/java.base/unix/native/include/jni_md.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_windows_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "3cacac1e4802ec246ea7c0c6772d4ac40c9f7255d4df095cfffe601137689771",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-23%2B20/src/java.base/windows/native/include/jni_md.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_license",
        downloaded_file_path = "LICENSE",
        sha256 = "4b9abebc4338048a7c2dc184e9f800deb349366bdf28eb23c2677a77b4c87726",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-23%2B20/LICENSE"],
    )

def rules_jni_dependencies():
    """Adds all external repositories required for rules_jni.

This should be called from a `WORKSPACE` file after the declaration of `fmeum_rules_jni` itself.

Currently, rules_jni depends on:

* [bazel_skylib](https://github.com/bazelbuild/bazel-skylib)
* [platforms](https://github.com/bazelbuild/platforms)
* [rules_license](https://github.com/bazelbuild/rules_license)
* individual files of the [OpenJDK](https://github.com/openjdk/jdk)

It also requires rules_cc 0.0.17 or later and rules_java 8.6.0 or later, which must be supplied by
the end user.
"""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "9f38886a40548c6e96c106b752f242130ee11aaa068a56ba7e56f4511f33e4f2",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.6.1/bazel-skylib-1.6.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.6.1/bazel-skylib-1.6.1.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "platforms",
        sha256 = "3384eb1c30762704fbe38e440204e114154086c8fc8a8c2e3e28441028c019a8",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/1.0.0/platforms-1.0.0.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/1.0.0/platforms-1.0.0.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "rules_license",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_license/releases/download/1.0.0/rules_license-1.0.0.tar.gz",
            "https://github.com/bazelbuild/rules_license/releases/download/1.0.0/rules_license-1.0.0.tar.gz",
        ],
        sha256 = "26d4021f6898e23b82ef953078389dd49ac2b5618ac564ade4ef87cced147b38",
    )
    jdk_deps()
