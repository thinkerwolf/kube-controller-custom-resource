#!/usr/bin/env bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

echo "SCRIPT_ROOT=" $SCRIPT_ROOT

go_path=""
if [ -n "$(go env GOPATH)" ]; then
    go_path=${go_path:-$(go env GOPATH)}
elif [ -n "$GOPATH" ]; then
    go_path=$GOPATH
else
    echo "Can't find GOPATH. exit"
    exit -1
fi
echo $go_path

# 指定code-generator根路径
CODEGEN_PKG="$go_path/src/k8s.io/code-generator"
# CODEGEN_PKG=${CODEGEN_PKG:-$(
#     cd "${SCRIPT_ROOT}"
#     ls -d -1 ./vendor/k8s.io/code-generator 2>/dev/null || echo ../code-generator
# )}
#CODEGEN_PKG="/Users/wukai/go/src/k8s.io/code-generator"
echo "CODEGEN_PKG=" $CODEGEN_PKG

source "${CODEGEN_PKG}/kube_codegen.sh"

# generate the code with:
# --output-base    because this script should also be able to run inside the vendor dir of
#                  k8s.io/kubernetes. The output-base is needed for the generators to output into the vendor dir
#                  instead of the $GOPATH directly. For normal projects this can be dropped.

kube::codegen::gen_helpers \
    --input-pkg-root github.com/thinkerwolf/kube-controller-custom-resource/pkg/apis \
    --output-base "$(dirname "${BASH_SOURCE[0]}")/../../../../" \
    --boilerplate "${SCRIPT_ROOT}/hack/boilerplate.go.txt"

kube::codegen::gen_client \
    --with-watch \
    --input-pkg-root github.com/thinkerwolf/kube-controller-custom-resource/pkg/apis \
    --output-pkg-root github.com/thinkerwolf/kube-controller-custom-resource/pkg/generated \
    --output-base "$(dirname "${BASH_SOURCE[0]}")/../../../../" \
    --boilerplate "${SCRIPT_ROOT}/hack/boilerplate.go.txt"