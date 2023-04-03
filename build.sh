#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s nullglob

pushd "$(dirname "$0")" &>/dev/null
repo="$PWD"

dockerTag="detectron2-builder"
docker build --progress plain -t "$dockerTag" .
# Use `-it` to ensure SIGINT and SIGTERM are passed.
# Ignore any message like `No CUDA runtime is found, using CUDA_HOME=/usr/local/cuda`. It's emitted by the PyTorch extension builder and only means no GPU is running. See https://github.com/pytorch/pytorch/blob/35b33095397a11e86f94f1c6820745fd6af68ec5/torch/utils/cpp_extension.py#L116.
mkdir -p dist
docker run --rm -it \
  --user $EUID:$EUID \
  --mount "type=bind,src=$repo/dist,dst=/out" \
  "$dockerTag" \
  bash -c 'cp -v /repo/dist/* /out/.'
popd
