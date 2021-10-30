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



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cc_jni_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="cc_jni_library-platforms"></a>platforms |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="cc_jni_library-cc_binary_args"></a>cc_binary_args |  <p align="center"> - </p>   |  none |


<a id="#java_jni_library"></a>

## java_jni_library

<pre>
java_jni_library(<a href="#java_jni_library-name">name</a>, <a href="#java_jni_library-native_libs">native_libs</a>, <a href="#java_jni_library-java_library_args">java_library_args</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="java_jni_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="java_jni_library-native_libs"></a>native_libs |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="java_jni_library-java_library_args"></a>java_library_args |  <p align="center"> - </p>   |  none |


