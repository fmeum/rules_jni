# Targets

rules_jni provides access to commonly used parts of the Java Native Interface (JNI) and convenience Java classes.

## `jni`

**Full label**: `@fmeum_rules_jni//jni` (long form: `@fmeum_rules_jni//jni:jni`)

This target can be added to the `deps` of a `cc_*` rule to get access to the `jni.h` header, which can be included via:

```c
#include <jni.h>
```

The correct version of the OS-specific `jni_md.h` header used internally by `jni.h` is inferred automatically from the
current target platform.

## `libjvm`

**Full label**: `@fmeum_rules_jni//jni:libjvm`

This library can be added to the `deps` of a `cc_*` target that requires access to
the [Java Invocation API](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/invocation.html).

**Note:** Every `cc_binary` that transitively depends on this library should also directly depend on it and call
`rules_jni_init` from its `main` function, providing `argv[0]`. This ensures that

This target serves as a drop-in replacement for the `jvm` shared library contained in JDKs and JREs, which is
called `jvm.dll`, `libjvm.dylib`
or `libjvm.so` depending on the OS. These libraries are usually not available in the standard locations searched by the
dynamic linker, which makes it difficult to run binaries linked against the original libraries on other machines.
The `libjvm` target solves this problem by providing a small stub library that locates and loads the real library at
runtime when its first symbol is accessed. Concretely, it tries the following in order:

1. Only when invoked via `bazel test`, as part of an action during the build or in any other situation where the
   environment variables for
   the [Bazel C++ runfiles library](https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h)
   are set, it locates the current Bazel Java runtime in the runfiles. It then looks for the `jvm` shared library
   relative to it at well-known locations, exiting if it cannot be found. using
   the [C++ runfiles library](https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h) and
   find the `jvm` shared library relative to it at well-known locations.

   **Note:** If you want this behavior also for binaries executed via `bazel run` or directly from `bazel-bin`, you have
   to:

    1. Depend on `@fmeum_rules_jni//jni:libjvm` directly from your top-level `cc_binary`.
    2. Add `#include <rules_jni.h>`.
    3. Call `rules_jni_init(const char* argv0)` from your `main` function, providing `argv[0]` as the argument.

2. Dynamically load the `jvm` shared library directly using the standard linker search path.

3. If `JAVA_HOME` is set, find the `jvm` shared library relative to it at well-known locations, exiting if it cannot be
   found.

4. If `PATH` is set, find the Java binary (`java` or `java.exe`) on it and try to load the `jvm` shared library from
   well-known locations relative to it, exiting if it cannot be found.

To get detailed runtime logs from this location procedure, set the environment variable `RULES_JNI_TRACE`.

**Note:** `libjvm` depends on
the [Bazel C++ runfiles library](https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h) and
thus on a C++ standard library. For C-only projects or release builds that are only run outside Bazel, consider
using [`libjvm_lite`](#libjvm_lite) instead.

## `libjvm_lite`

**Full label**: `@fmeum_rules_jni//jni:libjvm_lite`

This library can be added to the `deps` of a `cc_*` target that requires access to
the [Java Invocation API](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/invocation.html).

This target serves as a drop-in replacement for the `jvm` shared library contained in JDKs and JREs, which is
called `jvm.dll`, `libjvm.dylib`
or `libjvm.so` depending on the OS. These libraries are usually not available in the standard locations searched by the
dynamic linker, which makes it difficult to run binaries linked against the original libraries on other machines.
The `libjvm` target solves this problem by providing a small stub library that locates and loads the real library at
runtime when its first symbol is accessed. Concretely, it tries the following in order:

1. Dynamically load the `jvm` shared library directly using the standard linker search path.

2. If `JAVA_HOME` is set, find the `jvm` shared library relative to it at well-known locations, exiting if it cannot be
   found.

3. If `PATH` is set, find the Java binary (`java` or `java.exe`) on it and try to load the `jvm` shared library from
   well-known locations relative to it, exiting if it cannot be found.

To get detailed runtime logs from this location procedure, set the environment variable `RULES_JNI_TRACE`.

**Note:** `libjvm_lite` is very lightweight and written in C89. It only depends on a C standard library, as well as on
`libdl` on Unix. However, it will not automatically use the current Bazel Java runtime. If you want this behavior, use
[`libjvm`](#libjvm) instead.

## `native_loader`

**Full label**: `@fmeum_rules_jni//jni/tools/native_loader`

This library can be added to the `deps` of a `java_*` target and offers static methods that can be used to load native
libraries created with [`cc_jni_library`](rules.md#cc_jni_library) at runtime. See its
[javadocs](https://fmeum.github.io/rules_jni_javadocs/com/github/fmeum/rules_jni/RulesJni.html) for details.
