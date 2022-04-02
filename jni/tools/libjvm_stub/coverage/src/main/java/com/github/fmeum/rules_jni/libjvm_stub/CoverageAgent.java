// Copyright 2022 Fabian Meumertzheim
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

package com.github.fmeum.rules_jni.libjvm_stub;

import com.google.testing.coverage.JacocoCoverageRunner;
import java.io.File;
import java.io.IOException;
import java.lang.instrument.Instrumentation;
import java.net.URISyntaxException;
import java.util.jar.JarFile;

public final class CoverageAgent {
  public static void premain(String args, Instrumentation instrumentation) {
    switch (args) {
      case "classpath":
        appendSelfToBootstrapClassLoaderSearch(instrumentation);
        break;
      case "collect":
        try {
          JacocoCoverageRunner.main(new String[] {});
        } catch (Exception e) {
          error("Failed to collect coverage in JVM created via JNI_CreateJavaVM:", e);
        }
        break;
      default:
        error("Failed to initialize coverage agent in JVM created via JNI_CreateJavaVM:",
            new IllegalArgumentException("Unsupported argument: " + args));
    }
  }

  public static void main(String[] args) {
    // No-op, JVMs created via the Java Invocation API do not automatically execute the main method.
  }

  private static void appendSelfToBootstrapClassLoaderSearch(Instrumentation instrumentation) {
    try {
      JarFile ownJar = new JarFile(new File(
          CoverageAgent.class.getProtectionDomain().getCodeSource().getLocation().toURI()));
      instrumentation.appendToBootstrapClassLoaderSearch(ownJar);
    } catch (IOException | NullPointerException | URISyntaxException e) {
      warn(
          "Failed to append JaCoCo to bootstrap class loader search path, which may cause test failures",
          e);
    }
  }

  private static void error(String message, Throwable cause) {
    System.err.println("[rules_jni] " + message + ":");
    cause.printStackTrace();
    Runtime.getRuntime().halt(1);
  }

  private static void warn(String message, Throwable cause) {
    System.err.println("[rules_jni] " + message + ":");
    cause.printStackTrace();
  }
}
