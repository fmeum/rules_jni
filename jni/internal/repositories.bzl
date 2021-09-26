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
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_jni_h",
        downloaded_file_path = "jni.h",
        sha256 = "1266aea5b9f5d5db1cb6f8e5c6c43cfa7f80bc4f72d7fe42c6131bb939dc70f4",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-17-ga/src/java.base/share/native/include/jni.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_unix_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "88cb5c33e306900dd35a78d5a439087123b8e91b0986bb5acb42cc9bd2fcc42e",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-17-ga/src/java.base/unix/native/include/jni_md.h"],
    )
    maybe(
        http_file,
        name = "com_github_openjdk_jdk_windows_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "dbf96659c4c840b15ef40237db0c65657eca7a70904225fc984deb38999df515",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-17-ga/src/java.base/windows/native/include/jni_md.h"],
    )
    maybe(
        http_archive,
        name = "platforms",
        sha256 = "079945598e4b6cc075846f7fd6a9d0857c33a7afc0de868c2ccb96405225135d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
        ],
    )
