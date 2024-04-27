# Java Native Interface (JNI) rules for Bazel

![GitHub Actions](https://github.com/fmeum/rules_jni/workflows/Build%20all%20targets%20and%20run%20all%20tests/badge.svg)

rules_jni is a collection of Bazel rules for applications and libraries that mix Java/JVM and C/C++ code via the
[Java Native Interface (JNI)](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/index.html) or the
[Java Invocation API](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/invocation.html).

Currently, the rules cover the following use cases for mixed Java and native application or libraries that are currently
not covered by the native Bazel rules:

* building a native library for multiple platforms
* bundling a native library in a deploy JAR and loading the correct version at runtime
* access to the OS-specific JNI headers, even when cross-compiling or during multi-platform builds
* using the Java Invocation API to create or attach to a JVM, both with a Bazel-provided JDK and without Bazel

## Setup

If you are [MODULE.bazel](https://bazel.build/external/overview#bzlmod), add the following to your
`MODULE.bazel`:

```starlark
bazel_dep(name = "rules_jni", version = "<latest release>")
# Alternatively, to keep using the repository as @fmeum_rules_jni, use:
bazel_dep(name = "rules_jni", version = "<latest release>", repo_name = "fmeum_rules_jni")
```

Otherwise, add the following snippet to your `WORKSPACE`:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "fmeum_rules_jni",
    sha256 = "<sha of the release tarball>",
    strip_prefix = "rules_jni-<latest release>",
    url = "https://github.com/fmeum/rules_jni/archive/refs/tags/v<latest release>.tar.gz",
)

load("@fmeum_rules_jni//jni:repositories.bzl", "rules_jni_dependencies")

rules_jni_dependencies()
```

## Documentation

See the documentation for [targets](docs/targets.md), [rules](docs-gen/rules.md)
and [workspace macros](docs-gen/workspace_macros.md) provided by rules_jni.

## Examples

See [`tests/native_loader`](tests/native_loader) for an example of how to use rules_jni to create, package and use a
native library from Java. An example of a C++ application that starts a JVM and loads and executes Java code from its
Bazel runfiles using the
[Java Invocation API](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/invocation.html) can be found in
[`tests/libjvm_stub`](tests/libjvm_stub).

## Compatibility

rules_jni requires at least Bazel 6. For advanced use cases such as multi-platform native libraries,
enabling [`--incompatible_enable_cc_toolchain_resolution`](https://github.com/bazelbuild/bazel/issues/7260) is required (default in Bazel 7+).

## Multi-language coverage

rules_jni supports the generation of combined Java and C/C++ coverage reports for projects using `{cc,java}_jni_library`
and `@fmeum_rules_jni//jni:libjvm`. This feature currently has the following limitations:

* Only LLVM-based coverage toolchains with `llvm-profdata` are supported.
* When using the Java Invocation API to start a JVM from native code, `@fmeum_rules_jni//jni:libjvm` has to be used
  rather than `@fmeum_rules_jni//jni:libjvm_lite` and `rules_jni_init` has to be called.
* All jars on the classpath of a JVM started with `JNI_CreateJavaVM` have to be deploy jars.

To enable this feature, add the following lines to your project's `.bazelrc`:

```
# Always required.
coverage --combined_report=lcov
coverage --experimental_use_llvm_covmap
coverage --experimental_generate_llvm_lcov

# These flags ensure that the auto-configured C++ toolchain shipped with Bazel
# uses clang and the LLVM coverage tools. They may not be needed or have to be
# adapted if using a custom toolchain.
coverage --repo_env=CC=clang
coverage --repo_env=BAZEL_USE_LLVM_NATIVE_COVERAGE=1
coverage --repo_env=GCOV=llvm-profdata
```

Then, collect coverage and use [`genhtml`](https://linux.die.net/man/1/genhtml) to generate an HTML report:

```
bazel coverage //...
genhtml bazel-out/_coverage/_coverage_report.dat
```

## Projects using rules_jni

* [Jazzer](https://github.com/CodeIntelligenceTesting/jazzer): A coverage-guided, in-process fuzzer for the JVM.
