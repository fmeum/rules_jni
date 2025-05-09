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

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_jvm_external//:defs.bzl", "maven_install")

def rules_jni_tests_init():
    maven_install(
        artifacts = [
            "junit:junit:4.13.2",
            "net.bytebuddy:byte-buddy-agent:1.11.20",
        ],
        fail_if_repin_required = True,
        maven_install_json = Label("//:maven_install.json"),
        repositories = [
            "https://repo1.maven.org/maven2",
        ],
    )
    bazel_skylib_workspace()
