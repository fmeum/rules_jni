#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_jni-${TAG:1}"
ARCHIVE="rules_jni-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
## Using Bzlmod

Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_jni", version = "${TAG:1}")
\`\`\`

## Using WORKSPACE

Paste this snippet into your \`WORKSPACE.bazel\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_jni",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/fmeum/rules_jni/releases/download/${TAG}/${ARCHIVE}",
)

load("@rules_jni//jni:repositories.bzl", "rules_jni_dependencies")

rules_jni_dependencies()
EOF

echo "\`\`\`"
