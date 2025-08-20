#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# C++ & Java
find . -name '*.c' \
     -o -name '*.cpp' \
     -o -name '*.h' \
     -o -name '*.java' \
  | xargs clang-format-20 -i

# BUILD files
# go get github.com/bazelbuild/buildtools/buildifier
buildifier -r .

# Licence headers
# go install github.com/google/addlicense@latest
addlicense -c "Fabian Meumertzheim" docs/ jni/ tests/
