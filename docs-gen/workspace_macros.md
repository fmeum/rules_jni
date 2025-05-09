<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="rules_jni_dependencies"></a>

## rules_jni_dependencies

<pre>
load("@rules_jni//jni:repositories.bzl", "rules_jni_dependencies")

rules_jni_dependencies()
</pre>

Adds all external repositories required for rules_jni.

This should be called from a `WORKSPACE` file after the declaration of `fmeum_rules_jni` itself.

Currently, rules_jni depends on:

* [bazel_skylib](https://github.com/bazelbuild/bazel-skylib)
* [platforms](https://github.com/bazelbuild/platforms)
* [rules_license](https://github.com/bazelbuild/rules_license)
* individual files of the [OpenJDK](https://github.com/openjdk/jdk)

It also requires rules_cc 0.0.17 or later and rules_java 8.6.0 or later, which must be supplied by
the end user.



