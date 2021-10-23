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

def _merge_default_infos(ctx, infos):
    return DefaultInfo(
        files = depset(transitive = [info.files for info in infos]),
        runfiles = ctx.runfiles(
            transitive_files = depset(
                transitive = [info.default_runfiles.files for info in infos] + [info.data_runfiles.files for info in infos],
            ),
        ),
    )

def _merge_cc_infos_impl(ctx):
    return [
        _merge_default_infos(ctx, [lib[DefaultInfo] for lib in ctx.attr.libs]),
        cc_common.merge_cc_infos(direct_cc_infos = [lib[CcInfo] for lib in ctx.attr.libs]),
    ]

merge_cc_infos = rule(
    implementation = _merge_cc_infos_impl,
    attrs = {
        "libs": attr.label_list(
            providers = [CcInfo],
        ),
    },
    provides = [CcInfo],
)

def _merge_java_infos_impl(ctx):
    return [
        _merge_default_infos(ctx, [lib[DefaultInfo] for lib in ctx.attr.libs]),
        java_common.merge([lib[JavaInfo] for lib in ctx.attr.libs]),
    ]

merge_java_infos = rule(
    implementation = _merge_java_infos_impl,
    attrs = {
        "libs": attr.label_list(
            providers = [JavaInfo],
        ),
    },
    provides = [JavaInfo],
)

def make_root_relative(path, package = None):
    segments = []
    if native.repository_name() != "@":
        segments += ["external", native.repository_name().lstrip("@")]
    segments += (package or native.package_name()).split("/")
    segments += path.split("/")
    return "/".join(segments)
