## Android

When building for Android, you must build your Android rules using platforms. To do so, use the flag 
`--incompatible_enable_android_toolchain_resolution` and create a new platform rule, ex:

```
platform(
    name = "android_arm64",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:android",
    ],
    visibility = ["//:__subpackages__"],
)
```

and then set the Android platform using ```--android_platforms=//:android_arm64```

If you instead build using ```--fat_apk=arm64``` and ```--android_crosstool_top```, then you may end up
with ```<your_library>_linux_x86_64``` instead of ```<your_library>_android_aarch64```
(or a simillar error)
