<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#jni_headers"></a>

## jni_headers

<pre>
jni_headers(<a href="#jni_headers-name">name</a>, <a href="#jni_headers-lib">lib</a>)
</pre>


Generates the native headers for a `java_library` and exposes it to `cc_*` rules.

For every Java class `com.example.Foo` in the `java_library` target specified by `lib` that contains at least one
function marked with `native` or constant annotated with `@Native`, the include directory exported by this rule will
contain a file `com_example_Foo.h` that provides the C/C++ interface for this class. Consuming `cc_*` rules should have
this rule added to their `deps` and can then access such a header file via:

```c
#include "com_example_Foo.h"
```

This rule also directly exports the JNI header, which can be included via:

```c
#include <jni.h>
```

*Example:*

```starlark
load("@fmeum_rules_jni//jni:defs.bzl", "jni_headers")

java_library(
    name = "os_utils",
    ...
)

jni_headers(
    name = "os_utils_hdrs",
    lib = ":os_utils",
)

cc_library(
    name = "os_utils_impl",
    ...
    deps = [":os_utils_hdrs"],
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="jni_headers-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="jni_headers-lib"></a>lib |  The Java library for which native header files should be generated.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


<a id="#cc_jni_library"></a>

## cc_jni_library

<pre>
cc_jni_library(<a href="#cc_jni_library-name">name</a>, <a href="#cc_jni_library-platforms">platforms</a>, <a href="#cc_jni_library-cc_binary_args">cc_binary_args</a>)
</pre>

A native library that can be loaded by a Java application at runtime.

Add this target to the `native_libs` of a [`java_jni_library`](#java_jni_library).

The native libraries are exposed as Java resources, which are placed in a Java package determined from the Bazel
package of this target according to the
[Maven standard directory layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html).
If the library should be included in the `com/example` subdirectory of a deploy JAR, which corresponds to the Java
package `com.example`, place it under one of the following Bazel package structures:
* `**/src/*/native/com/example` (preferred)
* `**/src/*/resources/com/example`
* `**/src/*/java/com/example`
* `**/java/com/example`

*Note:* Building a native library for multiple platforms by setting the `platforms` attribute to a non-empty list of
platforms requires either remote execution or cross-compilation toolchains for the target platforms. As both require
a more sophisticated Bazel setup, the following simpler process can be helpful for smaller or open-source projects:

1. Leave the `platforms` attribute empty or unspecified.
2. Build the deploy JAR of the Java library or application with all native libraries included separately for each
   target platform, for example using a CI platform.
3. Manually (outside Bazel) merge the deploy JARs. The `.class` files will be identical and can thus safely be
   replaced, but the resulting JAR will include all versions of the native library and the correct version will be
   loaded at runtime.

An example of such a CI workflow can be found [here](https://github.com/CodeIntelligenceTesting/jazzer/blob/d1835d6fa2ebfb7b2661cfaaa8acb8bbf42bb486/.github/workflows/release.yml).


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cc_jni_library-name"></a>name |  A unique name for this target.   |  none |
| <a id="cc_jni_library-platforms"></a>platforms |  A list of [<code>platform</code>s](https://docs.bazel.build/versions/main/be/platform.html#platform) for which this native library should be built. If the list is empty (the default), the library is only built for the current target platform.   |  <code>[]</code> |
| <a id="cc_jni_library-cc_binary_args"></a>cc_binary_args |  Any arguments to a [<code>cc_library</code>](https://docs.bazel.build/versions/main/be/c-cpp.html#cc_library), except for: <code>linkshared</code> (always <code>True</code>), <code>linkstatic</code> (always <code>True</code>), <code>data</code> (runfiles are not supported)   |  none |


<a id="#java_jni_library"></a>

## java_jni_library

<pre>
java_jni_library(<a href="#java_jni_library-name">name</a>, <a href="#java_jni_library-native_libs">native_libs</a>, <a href="#java_jni_library-java_library_args">java_library_args</a>)
</pre>

A Java library that bundles one or more native libraries created with [`cc_jni_library`](#cc_jni_library).

To load a native library referenced in the `native_libs` argument, use the static methods of the
[`RulesJni`](https://fmeum.github.io/rules_jni_javadocs/com/github/fmeum/rules_jni/RulesJni.html) class, which is
accessible for `srcs` of this target due to an implicit dependency on
[`@fmeum_rules_jni//jni/tools/native_loader`](targets.md#native_loader). These methods automatically choose the
correct version of the library for the current OS and CPU architecture, if available.

The native libraries referenced in the `native_libs` argument are added as resources and are thus included in the
deploy JARs of any [`java_binary`](https://docs.bazel.build/versions/main/be/java.html#java_binary) depending on
this target.

### Implicit output targets

- `<name>.hdrs`: The auto-generated JNI headers for this library.

  This target can be added to the `deps` of a
  [`cc_library`](https://docs.bazel.build/versions/main/be/c-cpp.html#cc_library) or
  [`cc_jni_library`](#cc_jni_library). See [`jni_headers`](#jni_headers) for a more detailed description of the
  underlying rule.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="java_jni_library-name"></a>name |  A unique name for this target.   |  none |
| <a id="java_jni_library-native_libs"></a>native_libs |  A list of [<code>cc_jni_library</code>](#cc_jni_library) targets to include in this Java library.   |  <code>[]</code> |
| <a id="java_jni_library-java_library_args"></a>java_library_args |  Any arguments to a [<code>java_library</code>](https://docs.bazel.build/versions/main/be/java.html#java_library).   |  none |


