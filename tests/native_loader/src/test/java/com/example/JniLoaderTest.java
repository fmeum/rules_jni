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

package com.example;

import com.example.math.NativeMath;
import com.example.os.OsUtils;
import com.github.fmeum.rules_jni.RulesJni;
import org.junit.Assert;
import org.junit.Test;
import org.junit.function.ThrowingRunnable;

public class JniLoaderTest {
  @Test
  public void testFailuresCases() {
    Assert.assertThrows(
        NullPointerException.class, () -> RulesJni.loadLibrary(null, JniLoaderTest.class));
    Assert.assertThrows(
        NullPointerException.class, () -> RulesJni.loadLibrary("does_not_exist", (Class<?>) null));
    Assert.assertThrows(
        NullPointerException.class, () -> RulesJni.loadLibrary(null, "/com/example"));
    Assert.assertThrows(
        NullPointerException.class, () -> RulesJni.loadLibrary("does_not_exist", (String) null));
    Assert.assertThrows(UnsatisfiedLinkError.class,
        () -> RulesJni.loadLibrary("does_not_exist", JniLoaderTest.class));
  }

  @Test
  public void testNativeMath() {
    Assert.assertEquals(2, NativeMath.increment(1));
    Assert.assertEquals(5, NativeMath.add(2, 3));
  }

  @Test
  public void testOsUtils() {
    Assert.assertTrue(OsUtils.hasJniOnLoadBeenCalled);
    Assert.assertEquals(0, OsUtils.setenv("FOO", "BAR"));
  }
}
