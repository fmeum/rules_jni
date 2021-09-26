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

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/**
 * Static helper methods that load native libraries created with {@code java_native_library} rule of
 * <a href="https://github.com/fmeum/rules_jni">{@code rules_jni}</a>.
 */
public class RulesJni {
  private static Path tempDir;

  /**
   * Loads a native library created with the {@code java_native_library} rule from the resource
   * directory of the class
   * {@code inSamePackageAs}.
   *
   * The correct version of the native library for the current OS and CPU architecture is chosen
   * automatically.
   *
   * All temporary files created during the extraction of the native library are cleaned up at JVM
   * exit.
   *
   * @param name the name of the {@code java_native_library} target that generates the native
   *     library to be loaded.
   * @param inSamePackageAs a class that is contained in the same Java (or Bazel) package as the
   *     native library.
   * @throws NullPointerException if {@code name} or {@code inSamePackageAs} is {@code null}.
   * @throws SecurityException if a security manager exists and its checkLink method doesn't allow
   *     loading of the specified dynamic library.
   * @throws UnsatisfiedLinkError if a version of the library for the current OS and CPU
   *     architecture could not be found in the resource directory corresponding to {@code
   *     inSamePackageAs}.
   */
  public static void loadLibrary(String name, Class<?> inSamePackageAs) {
    URL libraryResource = inSamePackageAs.getResource(libraryRelativePath(name));
    failOnNullResource(libraryResource, name);
    loadLibrary(libraryResource);
  }

  /**
   * Loads a native library created with the {@code java_native_library} rule from the resource
   * directory specified by the absolute path {@code absolutePathToPackage}.
   *
   * The correct version of the native library for the current OS and CPU architecture is chosen
   * automatically.
   *
   * All temporary files created during the extraction of the native library are cleaned up at JVM
   * exit.
   *
   * @param name the name of the {@code java_native_library} target that generates the native
   *     library to be loaded.
   * @param absolutePathToPackage a class that is contained in the same Java (or Bazel) package as
   *     the native library.
   * @throws NullPointerException if {@code name} or {@code absolutePathToPackage} is {@code null}.
   * @throws SecurityException if a security manager exists and its checkLink method doesn't allow
   *     loading of the specified dynamic library.
   * @throws UnsatisfiedLinkError if a version of the library for the current OS and CPU
   *     architecture could not be found at specified resource path.
   */
  public static void loadLibrary(String name, String absolutePathToPackage) {
    if (absolutePathToPackage == null) {
      throw new NullPointerException("absolutePathToPackage must not be null");
    }
    URL libraryResource =
        RulesJni.class.getResource(absolutePathToPackage + "/" + libraryRelativePath(name));
    failOnNullResource(libraryResource, name);
    loadLibrary(libraryResource);
  }

  synchronized private static void loadLibrary(URL libraryResource) {
    try {
      Path tempDir = getOrCreateTempDir();
      Path tempFile = Files.createTempFile(tempDir, null, null);
      try (InputStream in = libraryResource.openStream()) {
        Files.copy(in, tempFile, StandardCopyOption.REPLACE_EXISTING);
        System.load(tempFile.toAbsolutePath().toString());
      } finally {
        tempFile.toFile().deleteOnExit();
      }
    } catch (IOException e) {
      throw new UnsatisfiedLinkError(e.getMessage());
    }
  }

  private static Path getOrCreateTempDir() throws IOException {
    if (tempDir == null) {
      tempDir = Files.createTempDirectory("rules_jni.");
      tempDir.toFile().deleteOnExit();
    }
    return tempDir;
  }

  private static String libraryRelativePath(String name) {
    if (name == null) {
      throw new NullPointerException("name must not be null");
    }
    return String.format("%s_%s_%s/%s", name, OsCpuUtils.CANONICAL_OS, OsCpuUtils.CANONICAL_CPU,
        System.mapLibraryName(name));
  }

  private static void failOnNullResource(URL resource, String name) {
    if (resource == null) {
      throw new UnsatisfiedLinkError(
          String.format("Can't find native library '%s' for OS '%s' (\"%s\") and CPU '%s' (\"%s\")",
              name, OsCpuUtils.CANONICAL_OS, OsCpuUtils.VERBOSE_OS, OsCpuUtils.CANONICAL_CPU,
              OsCpuUtils.VERBOSE_CPU));
    }
  }
}
