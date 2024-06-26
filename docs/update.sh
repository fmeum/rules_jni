#!/usr/bin/env bash
# Copyright 2021 Fabian Meumertzheim
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

set -euo pipefail

cd "$BUILD_WORKSPACE_DIRECTORY"

bazel build $(bazel query 'kind(stardoc, //docs:all)')

mkdir -p docs-gen
cp -fv bazel-bin/docs/rules.md docs-gen/rules.md
cp -fv bazel-bin/docs/workspace_macros.md docs-gen/workspace_macros.md
