/*
 * Copyright 2021 Fabian Meumertzheim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stddef.h>
#include <stdio.h>
#include <windows.h>

static const char* JAVA_EXECUTABLE = "\\java.exe";
static const char* LIBJVM_BASENAME = "jvm.dll";
static const char* PATH_ENV_SEPARATOR = ";";
static const char PATH_SEPARATOR = '\\';

static const char* LIBJVM_CANDIDATE_PATHS[] = {
    "\\bin\\server\\",
    "\\jre\\bin\\server\\",
};
static const size_t NUM_LIBJVM_CANDIDATE_PATHS =
    sizeof(LIBJVM_CANDIDATE_PATHS) / sizeof(char*);
static const size_t MAX_CANDIDATE_PATH_LENGTH = 16;

static int executable_exists(const char* path) {
  FILE* file;
  file = fopen(path, "r");
  if (file == NULL) {
    return -1;
  }
  fclose(file);
  return 0;
}

static void* load_library(const char* path) { return LoadLibrary(path); }

static void* load_symbol(void* library_handle, const char* symbol) {
  return GetProcAddress(library_handle, symbol);
}

static char* resolve_path(const char* path) {
  return _fullpath(NULL, path, 4096);
}
