<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#java_native_headers"></a>

## java_native_headers

<pre>
java_native_headers(<a href="#java_native_headers-name">name</a>, <a href="#java_native_headers-lib">lib</a>)
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
load("@fmeum_rules_jni//jni:defs.bzl", "java_native_headers")

java_library(
    name = "os_utils",
    ...
)

java_native_headers(
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
| <a id="java_native_headers-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="java_native_headers-lib"></a>lib |  The Java library for which native header files should be generated.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


<a id="#java_library_with_native"></a>

## java_library_with_native

<pre>
java_library_with_native(<a href="#java_library_with_native-name">name</a>, <a href="#java_library_with_native-native_libs">native_libs</a>, <a href="#java_library_with_native-tags">tags</a>, <a href="#java_library_with_native-visibility">visibility</a>, <a href="#java_library_with_native-java_library_args">java_library_args</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="java_library_with_native-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="java_library_with_native-native_libs"></a>native_libs |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_library_with_native-tags"></a>tags |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_library_with_native-visibility"></a>visibility |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_library_with_native-java_library_args"></a>java_library_args |  <p align="center"> - </p>   |  none |


<a id="#java_native_library"></a>

## java_native_library

<pre>
java_native_library(<a href="#java_native_library-name">name</a>, <a href="#java_native_library-java_lib">java_lib</a>, <a href="#java_native_library-platforms">platforms</a>, <a href="#java_native_library-tags">tags</a>, <a href="#java_native_library-visibility">visibility</a>, <a href="#java_native_library-cc_binary_args">cc_binary_args</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="java_native_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="java_native_library-java_lib"></a>java_lib |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_native_library-platforms"></a>platforms |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_native_library-tags"></a>tags |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_native_library-visibility"></a>visibility |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="java_native_library-cc_binary_args"></a>cc_binary_args |  <p align="center"> - </p>   |  none |


