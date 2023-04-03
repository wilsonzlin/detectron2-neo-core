#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s nullglob

pushd "$(dirname "$0")" &>/dev/null
repo="$PWD"
rm -rf build dist

# WARNING: Any versions other than these defaults are **untested**.
cuda="${CUDA_VERSION:-11.7}" # Should be `x.y`, not `x.y.z`.
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
RUN python$python -m pip install torch==$torch
RUN apt -y install ninja-build
RUN python$python -m pip install poetry2setup wheel
# Derived from upstream dev/packaging/{pkg_helpers.bash,build_wheel.sh}.
ENV FORCE_CUDA=1
# We intentionally don't use PTX, as it's not recommended for performance reasons according to PyTorch: https://pytorch.org/docs/stable/cpp_extension.html#torch.utils.cpp_extension.CUDAExtension. We intend to update this package frequently, so we can release support for newer CC as necessary.
ENV TORCH_CUDA_ARCH_LIST='3.7;5.0;5.2;5.3;6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6'
EOD
dockerTag="detectron2-builder-cuda$cuda-torch$torch"
docker build --progress plain -t "$dockerTag" .
# Use `-it` to ensure SIGINT and SIGTERM are passed.
# Ignore any message like `No CUDA runtime is found, using CUDA_HOME=/usr/local/cuda`. It's emitted by the PyTorch extension builder and only means no GPU is running. See https://github.com/pytorch/pytorch/blob/35b33095397a11e86f94f1c6820745fd6af68ec5/torch/utils/cpp_extension.py#L116.
docker run \
  --rm \
  -it \
  --mount "type=bind,src=$repo,dst=/repo" \
  --mount "type=tmpfs,dst=/.cache" \
  -w /repo \
  --user $EUID:$EUID \
  "$dockerTag" \
  bash -c "mkdir dist && \
    poetry2setup > setup.py && \
    python$python setup.py build bdist_wheel"
popd
