<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#rules_jni_dependencies"></a>

## rules_jni_dependencies

<pre>
rules_jni_dependencies()
</pre>

Adds all external repositories required for rules_jni.

This should be called from a `WORKSPACE` file after the declaration of `fmeum_rules_jni` itself.

Currently, rules_jni depends on:

* [bazel_skylib](https://github.com/bazelbuild/bazel-skylib)
* [platforms](https://github.com/bazelbuild/platforms)
* individual files of the [OpenJDK](https://github.com/openjdk/jdk)




