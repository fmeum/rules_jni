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

package com.example.math;

import com.github.fmeum.rules_jni.RulesJni;
import java.lang.annotation.Native;

public class NativeMath {
  static {
    RulesJni.loadLibrary("math", NativeMath.class);
    // Verify that loading the library twice does not result in errors.
    RulesJni.loadLibrary("math", NativeMath.class);
  }

  @Native private final static int incrementBy = 1;

  public static native int increment(int arg);
  public static native int add(int arg1, int arg2);
}
