workspace(name = "fmeum_rules_jni")

load("//jni:repositories.bzl", "rules_jni_dependencies")

rules_jni_dependencies()

local_repository(
    name = "fmeum_rules_jni_tests",
    path = "tests",
)

load("@fmeum_rules_jni_tests//:repositories.bzl", "rules_jni_tests_dependencies")

rules_jni_tests_dependencies()

load("@fmeum_rules_jni_tests//:init.bzl", "rules_jni_tests_init")

rules_jni_tests_init()

load("@fmeum_rules_jni_tests//:maven.bzl", "rules_jni_tests_maven_install")

rules_jni_tests_maven_install()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "c9794dcc8026a30ff67cf7cf91ebe245ca294b20b071845d12c192afe243ad72",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
    ],
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
