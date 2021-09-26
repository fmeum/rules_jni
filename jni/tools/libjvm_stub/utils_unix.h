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

#include <dlfcn.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static const char* JAVA_EXECUTABLE = "/java";
#ifdef __APPLE__
static const char* LIBJVM_BASENAME = "libjvm.dylib";
#else
static const char* LIBJVM_BASENAME = "libjvm.so";
#endif
static const char* PATH_ENV_SEPARATOR = ":";
static const char PATH_SEPARATOR = '/';

static const char* LIBJVM_CANDIDATE_PATHS[] = {
    "/lib/server/",
    "/lib/amd64/server/",
    "/jre/lib/server/",
    "/jre/lib/amd64/server/",
};
static const size_t NUM_LIBJVM_CANDIDATE_PATHS =
    sizeof(LIBJVM_CANDIDATE_PATHS) / sizeof(char*);
static const size_t MAX_CANDIDATE_PATH_LENGTH = 22;

static int executable_exists(const char* path) { return access(path, X_OK); }

static void* load_library(const char* path) {
  return dlopen(path, RTLD_LAZY | RTLD_LOCAL);
}

static void* load_symbol(void* library_handle, const char* symbol) {
  void* address = dlsym(library_handle, symbol);
  if (address == NULL) {
    fprintf(stderr, "%s\n", dlerror());
  }
  return address;
}

static char* resolve_path(const char* path) { return realpath(path, NULL); }
