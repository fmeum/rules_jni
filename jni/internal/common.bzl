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
        _merge_default_infos(ctx, [dep[DefaultInfo] for dep in ctx.attr.deps]),
        cc_common.merge_cc_infos(direct_cc_infos = [dep[CcInfo] for dep in ctx.attr.deps]),
        coverage_common.instrumented_files_info(
            ctx,
            dependency_attributes = ["deps"],
        ),
    ]

merge_cc_infos = rule(
    implementation = _merge_cc_infos_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [CcInfo],
        ),
    },
    provides = [CcInfo],
)

def _merge_java_infos_impl(ctx):
    return [
        _merge_default_infos(ctx, [dep[DefaultInfo] for dep in ctx.attr.deps]),
        java_common.merge([dep[JavaInfo] for dep in ctx.attr.deps]),
        coverage_common.instrumented_files_info(
            ctx,
            dependency_attributes = ["deps"],
        ),
    ]

merge_java_infos = rule(
    implementation = _merge_java_infos_impl,
    attrs = {
        "deps": attr.label_list(
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

def _force_java_identifier_char(c):
    if c.isalnum():
        return c
    else:
        return "_"

_INT_MIN = -2147483648

def _hash(string):
    return str(hash(string) - _INT_MIN)

def java_identifier(name):
    safe_name = "".join([_force_java_identifier_char(c) for c in name.elems()])
    if not safe_name or safe_name[0].isdigit():
        safe_name = "_" + safe_name
    return safe_name + "_" + _hash(name)

def jni_escaped_identifier(name):
    return java_identifier(name).replace("_", "_1")
