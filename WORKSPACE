workspace(name = "fmeum_rules_jni")

load("//jni:repositories.bzl", "rules_jni_dependencies")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")

rules_jni_dependencies()

# Direct development dependencies of @fmeum_rules_jni.
local_repository(
    name = "fmeum_rules_jni_tests",
    path = "tests",
)

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "c9794dcc8026a30ff67cf7cf91ebe245ca294b20b071845d12c192afe243ad72",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
    ],
)

http_archive(
    name = "rules_jvm_external",
    sha256 = "f36441aa876c4f6427bfb2d1f2d723b48e9d930b62662bf723ddfb8fc80f0140",
    strip_prefix = "rules_jvm_external-4.1",
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/4.1.zip",
)

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
