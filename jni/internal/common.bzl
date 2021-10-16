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

def _parse_same_repo_label(label, current_pkg):
    if label.startswith("//"):
        pkg_end = label.find(":")
        if pkg_end != -1:
            pkg = label[len("//"):pkg_end]
            name = label[pkg_end + len(":"):]
        else:
            pkg = label[len("//"):]
            name = pkg.split("/")[-1]
    else:
        pkg = current_pkg
        name = label.lstrip(":")

    return pkg, name

def parse_label(label, current_repo, current_pkg):
    if label.startswith("@"):
        repo_end = label.find("//")
        if repo_end != -1:
            repo = label[len("@"):repo_end]
            remainder = label[repo_end:]
        else:
            repo = label[len("@"):]
            remainder = "//:" + repo
    else:
        repo = current_repo
        remainder = label

    pkg, name = _parse_same_repo_label(remainder, current_pkg)
    return struct(
        repo = repo,
        pkg = pkg,
        name = name,
    )

def _stringify_label(label_struct):
    return "@{repo}//{pkg}:{name}".format(
        repo = label_struct.repo,
        pkg = label_struct.pkg,
        name = label_struct.name,
    )

def original_java_library_name(name):
    # TODO: Use java_common.stamp_jar to set the correct Target-Label attribute in the manifest.
    return "%s_remove_this_part_" % name

def original_java_library_label(label_string):
    label_struct = parse_label(
        label_string,
        current_repo = native.repository_name().lstrip("@"),
        current_pkg = native.package_name(),
    )
    return _stringify_label(struct(
        repo = label_struct.repo,
        pkg = label_struct.pkg,
        name = original_java_library_name(label_struct.name),
    ))
