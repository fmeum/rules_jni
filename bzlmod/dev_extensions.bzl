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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")
load(":local_repository.bzl", "starlarkified_local_repository")

def _install_dev_dependencies(ctx):
    starlarkified_local_repository(
        name = "fmeum_rules_jni_tests",
        path = "tests",
    )
    http_archive(
        name = "rules_jvm_external",
        sha256 = "f36441aa876c4f6427bfb2d1f2d723b48e9d930b62662bf723ddfb8fc80f0140",
        strip_prefix = "rules_jvm_external-4.1",
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/4.1.zip",
    )
    http_jar(
        name = "junit",
        sha256 = "8e495b634469d64fb8acfa3495a065cbacc8a0fff55ce1e31007be4c16dc57d3",
        urls = [
            "https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar",
        ],
    )
    http_jar(
        name = "byte_buddy_agent",
        sha256 = "1f83b9d2370d9a223fb31c3eb7f30bd74a75165c0630e9bc164355eb34cb6988",
        urls = [
            "https://repo1.maven.org/maven2/net/bytebuddy/byte-buddy-agent/1.11.20/byte-buddy-agent-1.11.20.jar",
        ],
    )

install_dev_dependencies = module_extension(
    implementation = _install_dev_dependencies,
)
