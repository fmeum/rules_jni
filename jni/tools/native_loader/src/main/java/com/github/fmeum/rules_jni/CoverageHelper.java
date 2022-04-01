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

package com.github.fmeum.rules_jni;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.stream.Collectors;

final class CoverageHelper {
  private static final String RUNTIME_OBJECTS_LIST_SUFFIX = "runtime_objects_list.txt";
  // We inject our coverage helpers under javax.* to make them less likely to be shaded to a
  // different name, which would break the native method lookup.
  private static final String COVERAGE_HELPERS_PACKAGE = "javax.com.github.fmeum.rules_jni.gen";

  static void collectNativeLibrariesCoverage(Map<String, NativeLibraryInfo> loadedLibs) {
    if (loadedLibs.isEmpty()) {
      return;
    }

    for (String libraryName : loadedLibs.keySet()) {
      writeCoverageFile(libraryName);
    }

    // collect_cc_coverage.sh emits its output at a fixed location relative to COVERAGE_DIR. In
    // order to ensure that multiple instances of rules_jni (in multiple java_binary targets or
    // shaded) do not interfere with each other when collecting coverage, copy all raw coverage
    // files into a temporary directory and generate the report there.
    Path tempCoverageDir;
    try {
      tempCoverageDir =
          Files.createTempDirectory(Paths.get(System.getenv("TEST_TMPDIR")), "rules_jni_coverage.");
    } catch (IOException e) {
      error(e);
      // Not reached.
      return;
    }

    Path coverageDir = Paths.get(System.getenv("COVERAGE_DIR"));
    File[] profrawFiles = coverageDir.toFile().listFiles((file, s) -> s.endsWith(".profraw"));
    if (profrawFiles != null) {
      try {
        for (File profrawFile : profrawFiles) {
          Files.copy(profrawFile.toPath(), tempCoverageDir.resolve(profrawFile.getName()));
        }
      } catch (IOException e) {
        error(e);
        // Not reached.
        return;
      }
    }

    Path collectCcCoverageScript = null;
    try {
      collectCcCoverageScript = Files.createTempFile(tempCoverageDir, "collect_cc_coverage", ".sh");
      try (InputStream stream = CoverageHelper.class.getResourceAsStream(
               "/bazel_tools/tools/test/collect_cc_coverage.sh")) {
        if (stream == null) {
          error("failed to find collect_cc_coverage.sh in resources");
          // Not reached.
          return;
        }
        Files.copy(stream, collectCcCoverageScript, StandardCopyOption.REPLACE_EXISTING);
      }
      if (!collectCcCoverageScript.toFile().setExecutable(true)) {
        error("failed to make collect_cc_coverage.sh executable");
        // Not reached.
        return;
      }
    } catch (IOException e) {
      error(e);
    }

    Path objectsBasePath =
        Paths.get(System.getenv("RUNFILES_DIR"), System.getenv("TEST_WORKSPACE"));
    String runtimeObjectsList =
        loadedLibs.values()
            .stream()
            .map(lib -> objectsBasePath.relativize(lib.tempFile.toPath()).toString())
            .collect(Collectors.joining("\n", "", "\n"));
    try {
      Path runtimeObjectsListFile =
          Files.createTempFile(tempCoverageDir, null, RUNTIME_OBJECTS_LIST_SUFFIX);
      Files.write(runtimeObjectsListFile, runtimeObjectsList.getBytes(StandardCharsets.UTF_8));
      Path coverageManifestFile = Files.createTempFile(tempCoverageDir, null, null);
      Files.write(coverageManifestFile,
          (runtimeObjectsListFile.toAbsolutePath() + "\n").getBytes(StandardCharsets.UTF_8));
      ProcessBuilder processBuilder =
          new ProcessBuilder()
              .command(collectCcCoverageScript.toAbsolutePath().toString())
              .directory(new File(System.getenv("ROOT")))
              .inheritIO();
      processBuilder.environment().put(
          "COVERAGE_MANIFEST", coverageManifestFile.toAbsolutePath().toString());
      processBuilder.environment().put("COVERAGE_DIR", tempCoverageDir.toAbsolutePath().toString());
      processBuilder.start().waitFor();
    } catch (IOException | InterruptedException e) {
      error(e);
    }

    Path tempCoverageOutput = tempCoverageDir.resolve("_cc_coverage.dat");
    if (!tempCoverageOutput.toFile().exists()) {
      error("coverage report at " + tempCoverageOutput + " failed to generate");
      // Not reached.
      return;
    }
    try {
      Path uniqueCoverageOutput = Files.createTempFile(coverageDir, "_cc_coverage.", ".dat");
      Files.move(tempCoverageOutput, uniqueCoverageOutput, StandardCopyOption.REPLACE_EXISTING);
    } catch (IOException e) {
      e.printStackTrace();
    }

    // We intentionally don't clean up the temporary files: They are only created when we run within
    // Bazel and thus land in the test's temporary directory, which is cleaned up by Bazel. By not
    // cleaning up ourselves, we make it easier to inspect the coverage files with --sandbox_debug.
  }

  private static void writeCoverageFile(String libraryName) {
    String helperClassName = COVERAGE_HELPERS_PACKAGE + "." + toJavaIdentifier(libraryName);
    try {
      Class<?> helperClass = Class.forName(helperClassName);
      Method writeCoverageFileMethod = helperClass.getMethod("writeCoverageFile");
      writeCoverageFileMethod.invoke(null);
    } catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException
        | InvocationTargetException | UnsatisfiedLinkError e) {
      error(e);
    }
  }

  private static void error(String message) {
    System.err.println("[rules_jni] Failed to collect coverage for native libraries: " + message);
    Runtime.getRuntime().halt(1);
  }

  private static void error(Throwable t) {
    System.err.println("[rules_jni] Failed to collect coverage for native libraries:");
    t.printStackTrace();
    Runtime.getRuntime().halt(1);
  }

  // Computes the same identifier as java_identifier in //jni/internal:common.bzl.
  private static String toJavaIdentifier(String name) {
    char[] safeChars = new char[name.length()];
    for (int i = 0; i < name.length(); i++) {
      char c = name.charAt(i);
      if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
        safeChars[i] = c;
      } else {
        safeChars[i] = '_';
      }
    }
    String safeName = new String(safeChars);
    if (safeChars.length == 0 || (safeChars[0] >= '0' && safeChars[0] <= '9')) {
      safeName = "_" + safeName;
    }
    return safeName + "_" + (((long) name.hashCode()) - Integer.MIN_VALUE);
  }
}
