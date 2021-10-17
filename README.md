# Java Native Interface (JNI) rules for Bazel
![GitHub Actions](https://github.com/fmeum/rules_jni/workflows/Build%20all%20targets%20and%20run%20all%20tests/badge.svg)

`rules_jni` is a collection of Bazel rules for applications and libraries that mix Java/JVM and C/C++ code via the [Java Native Interface (JNI)](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/index.html) or the [Java Incovation API](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/invocation.html).

## Setup

Add the following snippet to your `WORKSPACE`:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "fmeum_rules_jni",
    sha256 = "9d17a403ccb8b005fdb490a0e94942f163d55fdbb4a3e51fb135bd44e174d170",
    url = "https://github.com/fmeum/rules_jni/releases/download/v0.1.1/rules_jni-v0.1.1.tar.gz",
)

load("@fmeum_rules_jni//jni:repositories.bzl", "rules_jni_dependencies")

rules_jni_dependencies()
```

## Documentation

See the documentation for [targets](docs/targets.md), [rules](docs/rules.md)
and [workspace macros](docs/workspace_macros.md) provided by rules_jni.

## Compatibility

rules_jni heavily uses [platforms](https://docs.bazel.build/versions/main/platforms.html) and thus requires at least
Bazel 4.0.0. For advanced use cases such as multi-platform native libraries,
enabling [`--incompatible_enable_cc_toolchain_resolution`](https://github.com/bazelbuild/bazel/issues/7260) is required
for Bazel 4.
