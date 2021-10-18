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

import java.lang.instrument.Instrumentation;
import net.bytebuddy.agent.ByteBuddyAgent;

public class HelloFromJava {
  public static String helloFromJava() {
    // On Windows, the library search path is governed by PATH. If we are in a test that clears out
    // PATH, the native "instrument" agentlib that takes care of attaching a Java agent cannot be
    // loaded as its dynamic dependencies cannot be found. Hence, we do not fail in this case.
    String path = System.getenv("PATH");
    boolean shouldBeAbleToAttachAgent =
        !System.getProperty("os.name").startsWith("Windows") || (path != null && !path.isEmpty());
    try {
      Instrumentation instrumentation = ByteBuddyAgent.install();
      if (shouldBeAbleToAttachAgent && instrumentation == null) {
        System.err.println("Failed to attach a Java agent");
        System.exit(1);
      };
    } catch (IllegalStateException e) {
      if (shouldBeAbleToAttachAgent) {
        throw e;
      }
    }
    return System.getProperty("msg.hello");
  }
}
