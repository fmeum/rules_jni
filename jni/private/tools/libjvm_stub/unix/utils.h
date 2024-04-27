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
#ifdef __APPLE__
#include <string.h>
#include <sys/syslimits.h>
#endif
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

static char* our_strdup(const char* src);

/* The returned string has to be freed by the caller. */
static char* get_env_copy(const char* key) {
  const char* value = getenv(key);
  if (value == NULL) {
    return NULL;
  }
  return our_strdup(value);
}

/* The returned string has to be freed by the caller. */
static char* get_java_home_fallback() {
#ifdef __APPLE__
  char* res = NULL;
  FILE* pipe = NULL;
  char buffer[PATH_MAX];

  /* java_home prints the JAVA_HOME of the default installation to stdout.
   * Silence warnings by redirecting stderr to /dev/null. */
  pipe = popen("/usr/libexec/java_home 2> /dev/null", "r");
  if (pipe == NULL) {
    goto cleanup;
  }

  res = fgets(buffer, sizeof(buffer), pipe);
  if (res == NULL || strcmp(res, "") == 0) {
    goto cleanup;
  }

  /* The output of java_home is terminated by a newline. Skip over it. */
  res[strlen(res) - 1] = '\0';
  res = our_strdup(res);

cleanup:
  if (pipe != NULL) {
    pclose(pipe);
  }

  return res;
#else
  return NULL;
#endif
}

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
