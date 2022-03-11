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

class NativeLibraryInfo {
  public final String canonicalPath;
  public final File tempFile;

  NativeLibraryInfo(String canonicalPath, File tempFile) {
    this.canonicalPath = canonicalPath;
    this.tempFile = tempFile;
  }
}
