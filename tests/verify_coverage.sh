#!/usr/bin/env bash
# Copyright 2022 Fabian Meumertzheim
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

report=bazel-out/_coverage/_coverage_report.dat

find native_loader/src/main libjvm_stub -type f \
 \( -name '*.java' -o -name '*.cpp' -o -name '*.c' -a ! -name 'hermetic_release_failure_test.c' \) \
 -print0 | while read -r -d $'\0' file
do
  pattern=$(basename "$file")
  if grep -q "$pattern" "$report";
  then
    echo "Coverage report contains $pattern"
  else
    echo "Coverage report is missing $pattern:"
    cat "$report"
    exit 1
  fi
done

if grep -q "__llvm_profile_write_file" "$report";
then
  echo "Coverage report mentions internal function __llvm_profile_write_file:"
  cat "$report"
  exit 1
else
  echo "Coverage report expectedly does not contain internal functions"
fi
