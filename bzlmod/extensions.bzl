load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _download_jni_headers(ctx):
    http_file(
        name = "com_github_openjdk_jdk_jni_h",
        downloaded_file_path = "jni.h",
        sha256 = "1266aea5b9f5d5db1cb6f8e5c6c43cfa7f80bc4f72d7fe42c6131bb939dc70f4",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-17-ga/src/java.base/share/native/include/jni.h"],
    )
    http_file(
        name = "com_github_openjdk_jdk_unix_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "88cb5c33e306900dd35a78d5a439087123b8e91b0986bb5acb42cc9bd2fcc42e",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-17-ga/src/java.base/unix/native/include/jni_md.h"],
    )
    http_file(
        name = "com_github_openjdk_jdk_windows_jni_md_h",
        downloaded_file_path = "jni_md.h",
        sha256 = "dbf96659c4c840b15ef40237db0c65657eca7a70904225fc984deb38999df515",
        urls = ["https://raw.githubusercontent.com/openjdk/jdk/jdk-17-ga/src/java.base/windows/native/include/jni_md.h"],
    )

download_jni_headers = module_extension(
    implementation = _download_jni_headers,
)
