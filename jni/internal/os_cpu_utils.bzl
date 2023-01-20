# Copyright 2021 Fabian Meumertzheim
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CPUS = [
    "aarch64",
    "arm",
    "mips64",
    "ppc",
    "riscv64",
    "s390x",
    "x86_32",
    "x86_64",
]

OSES = [
    "freebsd",
    "linux",
    "macos",
    "openbsd",
    "windows",
    "android",
]

SELECT_TARGET_CPU = select({
    "@platforms//cpu:%s" % cpu: cpu
    for cpu in CPUS
})

SELECT_TARGET_OS = select({
    "@platforms//os:%s" % os: os
    for os in OSES
})
