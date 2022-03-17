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

## `libjvm`, `libjvm_lite`

**Full labels**: `@fmeum_rules_jni//jni:libjvm`, `@fmeum_rules_jni//jni:libjvm_lite`

This library can be added to the `deps` of a `cc_*` target that requires access to
the [Java Invocation API](https://docs.oracle.com/en/java/javase/17/docs/specs/jni/invocation.html).

This target serves as a drop-in replacement for the `jvm` shared library contained in JDKs and JREs, which is
called `jvm.dll`, `libjvm.dylib`
or `libjvm.so` depending on the OS. These libraries are usually not available in the standard locations searched by the
dynamic linker, which makes it difficult to run binaries linked against the original libraries on other machines.
The `libjvm` target solves this problem by providing a small stub library that locates and loads the real library at
runtime when its first symbol is accessed. Concretely, it does the following in order:

1. (`libjvm` only) When invoked via `bazel test`, as part of an action during the build or in any other situation where
   the [Bazel C++ runfiles library](https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h)
   finds a runfiles directory or manifest, locate the current Bazel Java runtime in the runfiles and look for the `jvm`
   shared library relative to it at well-known locations. If it cannot be found, print a warning and continue.

   **Note:** To ensure that the current Bazel Java runtime is also found if the binary is executed via `bazel run` or
   directly from `bazel-bin` and to ensure that Java code can find its runfiles, do the following:

    1. Depend on `@fmeum_rules_jni//jni:libjvm` directly from the top-level `cc_binary`.
    2. Add `#include <rules_jni.h>`.
    3. Call `rules_jni_init(const char* argv0)` from the `main` function, providing `argv[0]` as the argument. This
       call is **not thread-safe** as it modifies the environment.

   If you want this lookup to succeed also for binaries executed by other binaries that are themselves run from Bazel,
   [set the environment variables required for runfiles discovery](https://github.com/bazelbuild/bazel/blob/e8a066e9e625a136363338d10f03ed14c26dedfa/tools/cpp/runfiles/runfiles_src.h#L58).

2. Dynamically load the `jvm` shared library directly using the standard linker search path.

3. If `JAVA_HOME` is set, find the `jvm` shared library relative to it at well-known locations, exiting if it cannot be
   found.

4. (macOS only) Execute `/usr/libexec/java_home` and use its output as a replacement for `JAVA_HOME`.

5. If `PATH` is set, find the Java binary (`java` or `java.exe`) on it and try to load the `jvm` shared library from
   well-known locations relative to it, exiting if it cannot be found.

To get detailed runtime logs from this location procedure, set the environment variable `RULES_JNI_TRACE` to a non-empty
value.

**Note:** `libjvm` depends on
the [Bazel C++ runfiles library](https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h) and
thus on a C++ standard library. For C-only projects or release builds that are only run outside Bazel, consider
using [`libjvm_lite`](#libjvm_lite) instead.

## `native_loader`

**Full label**: `@fmeum_rules_jni//jni/tools/native_loader`

This library can be added to the `deps` of a `java_*` target and offers static methods that can be used to load native
libraries created with [`cc_jni_library`](rules.md#cc_jni_library) at runtime. See its
[javadocs](https://fmeum.github.io/rules_jni_javadocs/com/github/fmeum/rules_jni/RulesJni.html) for details.
