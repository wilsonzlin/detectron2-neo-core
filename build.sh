#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s nullglob

pushd "$(dirname "$0")" &>/dev/null
repo="$PWD"
rm -rf build dist

# Any versions other than these defaults are **untested**.
cuda="${CUDA_VERSION:-11.8}" # Should be `x.y`, not `x.y.z`.
torch="${TORCH_VERSION:-2.0.0}" # Should be exact i.e. `x.y.z`.
python="${PYTHON_VERSION:-3.11}" # Should be `x.y`, not `x.y.z`.

# We chose Ubuntu 18.04 because:
# - It's old, so built binaries will be more compatible.
# - The *deadsnakes* PPA is available for Ubuntu, which provides a lot of Python builds.
# - *deadsnakes* has the most Python version builds for 18.04.

# Until `poetry build` "just works", we'll resort to generating a setup.py and using `wheel` instead.

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
