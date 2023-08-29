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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//jni/internal:repositories.bzl", "jdk_deps")

def _download_jdk_deps_impl(ctx):
    jdk_deps()
    extension_metadata = getattr(ctx, "extension_metadata", None)
    if extension_metadata:
        return extension_metadata(
            root_module_direct_deps = "all",
            root_module_direct_dev_deps = [],
        )

download_jdk_deps = module_extension(
    implementation = _download_jdk_deps_impl,
)
