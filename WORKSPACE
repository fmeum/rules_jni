workspace(name = "fmeum_rules_jni")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")
load("//jni:repositories.bzl", "rules_jni_dependencies")

rules_jni_dependencies()

# Direct development dependencies of @fmeum_rules_jni.
local_repository(
    name = "fmeum_rules_jni_tests",
    path = "tests",
)

http_archive(
    name = "build_bazel_apple_support",
    sha256 = "c4bb2b7367c484382300aee75be598b92f847896fb31bbd22f3a2346adf66a80",
    url = "https://github.com/bazelbuild/apple_support/releases/download/1.15.1/apple_support.1.15.1.tar.gz",
)

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

http_archive(
    name = "rules_jvm_external",
    sha256 = "b17d7388feb9bfa7f2fa09031b32707df529f26c91ab9e5d909eb1676badd9a6",
    strip_prefix = "rules_jvm_external-4.5",
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/4.5.zip",
)

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "4441a965c97f8364c8eb901f951ca9a15c6e2c29ee0f10b56bf8b563463752ea",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.6.0/stardoc-0.6.0.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.6.0/stardoc-0.6.0.tar.gz",
    ],
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")

rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")

rules_jvm_external_setup()

load("@io_bazel_stardoc//:deps.bzl", "stardoc_external_deps")

stardoc_external_deps()

load("@stardoc_maven//:defs.bzl", stardoc_pinned_maven_install = "pinned_maven_install")

stardoc_pinned_maven_install()

# Transitive dependencies required for @fmeum_rules_jni_tests.
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

register_toolchains(
    "@bazel_skylib//toolchains/unittest:cmd_toolchain",
    "@bazel_skylib//toolchains/unittest:bash_toolchain",
)
