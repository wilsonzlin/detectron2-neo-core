#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s nullglob

pushd "$(dirname "$0")" &>/dev/null
repo="$PWD"
rm -rf build dist

cuda="$CUDA_VERSION" # Should be `x.y`, not `x.y.z`.
torch="$TORCH_VERSION" # Should be exact i.e. `x.y.z`.
python="$PYTHON_VERSION" # Should be `x.y`, not `x.y.z`.

pushd "$(mktemp -d)"
cat <<EOD > Dockerfile
FROM nvidia/cuda:$cuda.0-devel-ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update
RUN apt -y install software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt -y install python$python-dev python$python-full
RUN python$python -m ensurepip
RUN python$python -m pip install torch==$torch --index-url https://download.pytorch.org/whl/cu$(echo "$cuda" | sed 's/\.//')
RUN apt -y install ninja-build
RUN python$python -m pip install poetry2setup wheel
EOD
dockerTag="detectron2-builder-cuda$cuda-torch$torch"
docker build --progress plain -t "$dockerTag" .
# Use `-it` to ensure SIGINT and SIGTERM are passed.
docker run \
  --rm \
  -it \
  --mount "type=bind,src=$repo,dst=/repo" \
  --mount "type=tmpfs,dst=/.cache" \
  -w /repo \
  -e "CUDA_HOME=/usr/loca/cuda-$cuda" \
  --user $EUID:$EUID \
  "$dockerTag" \
  bash -c "mkdir dist && \
    poetry2setup > setup.py && \
    python$python setup.py build bdist_wheel"
popd
