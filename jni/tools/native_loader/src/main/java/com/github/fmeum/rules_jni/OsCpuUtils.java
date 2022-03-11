// Copyright 2021 Fabian Meumertzheim
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.github.fmeum.rules_jni;

final class OsCpuUtils {
  public static final String VERBOSE_OS = System.getProperty("os.name");
  public static final String CANONICAL_OS = toCanonicalOs(VERBOSE_OS);

  public static final String VERBOSE_CPU = System.getProperty("os.arch");
  public static final String CANONICAL_CPU = toCanonicalCpu(VERBOSE_CPU);

  private OsCpuUtils() {}

  private static String toCanonicalOs(String verboseOs) {
    if (verboseOs.startsWith("Mac OS X"))
      return "macos";
    else if (verboseOs.startsWith("FreeBSD"))
      return "freebsd";
    else if (verboseOs.startsWith("OpenBSD"))
      return "openbsd";
    else if (verboseOs.startsWith("Linux"))
      return "linux";
    else if (verboseOs.startsWith("Windows"))
      return "windows";
    return "unknown";
  }

  private static String toCanonicalCpu(String verboseCpu) {
    switch (verboseCpu) {
      case "i386":
      case "i486":
      case "i586":
      case "i686":
      case "i786":
      case "x86":
        return "x86_32";
      case "amd64":
      case "x86_64":
      case "x64":
        return "x86_64";
      case "ppc":
      case "ppc64":
      case "ppc64le":
        return "ppc";
      case "arm":
      case "armv7l":
        return "arm";
      case "aarch64":
        return "aarch64";
      case "s390x":
      case "s390":
        return "s390x";
      case "mips64el":
      case "mips64":
        return "mips64";
      case "riscv64":
        return "riscv64";
      default:
        return "unknown";
    }
  }
}
