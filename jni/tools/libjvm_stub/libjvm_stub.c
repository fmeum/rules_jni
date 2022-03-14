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

// clang-format: off
#define _JNI_IMPLEMENTATION_
#include <jni.h>
// clang-format: on

#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "utils.h"

#define MSG_PREFIX "[rules_jni]: "

char* rules_jni_internal_get_bazel_java_home();

typedef jint (*JNI_GetDefaultJavaVMInitArgs_t)(void*);
typedef jint (*JNI_CreateJavaVM_t)(JavaVM**, void**, void*);
typedef jint (*JNI_GetCreatedJavaVMs_t)(JavaVM**, jsize, void*);

static JNI_GetDefaultJavaVMInitArgs_t JNI_GetDefaultJavaVMInitArgs_ = NULL;
static JNI_CreateJavaVM_t JNI_CreateJavaVM_ = NULL;
static JNI_GetCreatedJavaVMs_t JNI_GetCreatedJavaVMs_ = NULL;

static int tracing_enabled = 0;

static void trace(const char* fmt, ...) {
  if (tracing_enabled == 0) {
    return;
  }
  va_list args;
  va_start(args, fmt);
  fprintf(stderr, MSG_PREFIX);
  vfprintf(stderr, fmt, args);
  fprintf(stderr, "\n");
  va_end(args);
}

static char* our_strdup(const char* src) {
  char* dst;
  size_t len;

  len = strlen(src) + 1;
  dst = malloc(len);
  if (dst == NULL) {
    return NULL;
  }
  memcpy(dst, src, len);
  return dst;
}

static int try_load_libjvm(const char* path) {
  void* handle;

  trace("Trying to load libjvm from: %s", path);
  handle = load_library(path);
  if (handle == NULL) {
    return -1;
  }

  JNI_GetDefaultJavaVMInitArgs_ = (JNI_GetDefaultJavaVMInitArgs_t)load_symbol(
      handle, "JNI_GetDefaultJavaVMInitArgs");
  if (JNI_GetDefaultJavaVMInitArgs_ == NULL) {
    exit(EXIT_FAILURE);
  }

  JNI_CreateJavaVM_ =
      (JNI_CreateJavaVM_t)load_symbol(handle, "JNI_CreateJavaVM");
  if (JNI_CreateJavaVM_ == NULL) {
    exit(EXIT_FAILURE);
  }

  JNI_GetCreatedJavaVMs_ =
      (JNI_GetCreatedJavaVMs_t)load_symbol(handle, "JNI_GetCreatedJavaVMs");
  if (JNI_GetCreatedJavaVMs_ == NULL) {
    exit(EXIT_FAILURE);
  }

  return 0;
}

static int try_load_libjvm_under_basepath(const char* basepath) {
  size_t basepath_length;
  size_t i;
  size_t max_path_length;
  char* path;
  int res = -1;

  basepath_length = strlen(basepath);
  max_path_length =
      basepath_length + MAX_CANDIDATE_PATH_LENGTH + strlen(LIBJVM_BASENAME) + 1;
  path = (char*)malloc(max_path_length);
  if (path == NULL) {
    perror(MSG_PREFIX "Failed to allocate buffer for libjvm path");
    exit(EXIT_FAILURE);
  }
  strcpy(path, basepath);

  for (i = 0; i < NUM_LIBJVM_CANDIDATE_PATHS; ++i) {
    path[basepath_length] = '\0';
    strcat(path, LIBJVM_CANDIDATE_PATHS[i]);
    strcat(path, LIBJVM_BASENAME);

    res = try_load_libjvm(path);
    if (res == 0) {
      goto cleanup;
    }
  }

cleanup:
  free(path);
  return res;
}

/* The returned string has to be freed by the caller. */
static char* find_java_executable() {
  char* java_path_candidate = NULL;
  char* path_env;
  const char* path_env_entry;
  char* res = NULL;

  path_env = get_env_copy("PATH");
  if (path_env == NULL) {
    trace("PATH not set");
    goto cleanup;
  }
  trace("PATH is set: %s", path_env);

  path_env_entry = strtok(path_env, PATH_ENV_SEPARATOR);
  while (path_env_entry) {
    java_path_candidate =
        (char*)malloc(strlen(path_env_entry) + strlen(JAVA_EXECUTABLE) + 1);
    if (java_path_candidate == NULL) {
      perror(MSG_PREFIX "Failed to allocate java path buffer");
      exit(EXIT_FAILURE);
    }
    strcpy(java_path_candidate, path_env_entry);
    strcat(java_path_candidate, JAVA_EXECUTABLE);
    if (executable_exists(java_path_candidate) == 0) {
      trace("Found java executable at: %s", java_path_candidate);
      /* We usually found a path like /usr/bin/java and now have to follow all
       * symlinks. */
      res = resolve_path(java_path_candidate);
      if (res == NULL) {
        fprintf(stderr, MSG_PREFIX "Failed to resolve path %s: %s\n",
                java_path_candidate, strerror(errno));
        exit(EXIT_FAILURE);
      }
      trace("Using fully resolved path to java: %s", res);
      goto cleanup;
    }
    trace("Does not exist or not executable: %s", java_path_candidate);

    free(java_path_candidate);
    java_path_candidate = NULL;
    path_env_entry = strtok(NULL, PATH_ENV_SEPARATOR);
  }
  trace("java executable not found in PATH");

cleanup:
  free(path_env);
  free(java_path_candidate);
  return res;
}

/* The returned string has to be freed by the caller. */
static char* find_java_home() {
  char* java_home_fallback = NULL;
  char* java_executable_path = NULL;
  char* pos;
  size_t separator_count_from_end;
  char* res = NULL;

  res = get_env_copy("JAVA_HOME");
  if (res != NULL) {
    trace("JAVA_HOME is set: %s", res);
    return res;
  }

  java_home_fallback = get_java_home_fallback();
  if (java_home_fallback != NULL) {
    trace("get_java_home_fallback() returned: %s", java_home_fallback);
    return java_home_fallback;
  }

  java_executable_path = find_java_executable();
  if (java_executable_path == NULL) {
    return NULL;
  }
  /* The path to the java executable ends with /bin/java(.exe), which we have to
   * strip of to get the equivalent of JAVA_HOME. Traverse it from the end and
   * stop at the second-to-last occurence of the path separator. */
  pos = strrchr(java_executable_path, '\0');
  separator_count_from_end = 0;
  for (; pos != java_executable_path; --pos) {
    if (*pos == PATH_SEPARATOR) {
      ++separator_count_from_end;
    }
    if (separator_count_from_end == 2) {
      /* Cut off /bin/java(.exe) in-place. */
      *pos = '\0';
      trace("Detected JAVA_HOME as: %s", java_executable_path);
      return java_executable_path;
    }
  }

  return NULL;
}

static void init() {
  int res;
  const char* bazel_java_home = NULL;
  char* java_home = NULL;

  if (getenv("RULES_JNI_TRACE") != NULL) {
    tracing_enabled = 1;
  }

  bazel_java_home = rules_jni_internal_get_bazel_java_home();
  if (bazel_java_home != NULL) {
    trace("Found Bazel JAVA_HOME: %s", bazel_java_home);
    res = try_load_libjvm_under_basepath(bazel_java_home);
    if (res == 0) {
      goto cleanup;
    }
  }

  res = try_load_libjvm(LIBJVM_BASENAME);
  if (res == 0) {
    goto cleanup;
  }

  java_home = find_java_home();
  if (java_home == NULL) {
    goto cleanup;
  }
  res = try_load_libjvm_under_basepath(java_home);

cleanup:
  free(java_home);

  if (res < 0) {
    fprintf(stderr,
            MSG_PREFIX
            "Failed to find %s. Add it to the library search path or set "
            "JAVA_HOME.\n",
            LIBJVM_BASENAME);
    exit(EXIT_FAILURE);
  } else {
    trace("Success");
  }
}

JNIEXPORT jint JNICALL JNI_GetDefaultJavaVMInitArgs(void* args) {
  if (JNI_GetDefaultJavaVMInitArgs_ == NULL) {
    init();
  }
  return JNI_GetDefaultJavaVMInitArgs_(args);
}

JNIEXPORT jint JNICALL JNI_CreateJavaVM(JavaVM** pvm, void** penv, void* args) {
  if (JNI_CreateJavaVM_ == NULL) {
    init();
  }
  return JNI_CreateJavaVM_(pvm, penv, args);
}

JNIEXPORT jint JNICALL JNI_GetCreatedJavaVMs(JavaVM** pvm, jsize sbuf,
                                             jsize* nvms) {
  if (JNI_GetCreatedJavaVMs_ == NULL) {
    init();
  }
  return JNI_GetCreatedJavaVMs_(pvm, sbuf, nvms);
}

/*
 * jni.h labels its functions with __declspec(dllimport), which makes client
 * code look for their address in a global variable with the __imp_ prefix.
 */
void* __imp_JNI_GetDefaultJavaVMInitArgs = JNI_GetDefaultJavaVMInitArgs;
void* __imp_JNI_CreateJavaVM = JNI_CreateJavaVM;
void* __imp_JNI_GetCreatedJavaVMs = JNI_GetCreatedJavaVMs;
