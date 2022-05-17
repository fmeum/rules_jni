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

package com.example.os;

import com.github.fmeum.rules_jni.RulesJni;

public class OsUtils {
  public static boolean hasJniOnLoadBeenCalled = false;

  static {
    String packagePath = OsUtils.class.getPackage().getName().replace(".", "/");
    RulesJni.loadLibrary("impl/os", "/" + packagePath);
    // Verify that loading the library twice does not result in errors.
    RulesJni.loadLibrary("impl/os", OsUtils.class);
  }

  public static native int setenv(String name, String value);

  private OsUtils() {}
}
