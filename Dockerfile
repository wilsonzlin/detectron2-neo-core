# WARNING: Any versions other than these defaults are **untested**.
# Should be `x.y`, not `x.y.z`.
ARG CUDA_VERSION=11.7
# Should be exact i.e. `x.y.z`.
ARG PYTHON_VERSION=3.11
# Should be `x.y`, not `x.y.z`.
ARG TORCH_VERSION=2.0.0

# We chose Ubuntu 18.04 because:
# - It's old, so built binaries will be more compatible.
# - The *deadsnakes* PPA is available for Ubuntu, which provides a lot of Python builds.
# - *deadsnakes* has the most Python version builds for 18.04.
# WARNING: We must spell out `python$PYTHON_VERSION` as changing the built-in `python3` in Ubuntu is unsafe.
FROM nvidia/cuda:$CUDA_VERSION.0-devel-ubuntu18.04
# ARGs are deleted after FROM.
ARG CUDA_VERSION
ARG PYTHON_VERSION
ARG TORCH_VERSION
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update
RUN apt -y install ninja-build software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt -y install python$PYTHON_VERSION-dev python$PYTHON_VERSION-full
RUN python$PYTHON_VERSION -m ensurepip

# Until `poetry build` "just works", we'll resort to generating a setup.py and using `wheel` instead.
# Install wheel before installing torch as the latter requires the former.
RUN python$PYTHON_VERSION -m pip install poetry2setup wheel
RUN python$PYTHON_VERSION -m pip install torch==$TORCH_VERSION
# Derived from upstream dev/packaging/{pkg_helpers.bash,build_wheel.sh}.
ENV FORCE_CUDA=1
# We intentionally don't use PTX, as it's not recommended for performance reasons according to PyTorch: https://pytorch.org/docs/stable/cpp_extension.html#torch.utils.cpp_extension.CUDAExtension. We intend to update this package frequently, so we can release support for newer CC as necessary.
ENV TORCH_CUDA_ARCH_LIST='3.7;5.0;5.2;5.3;6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6'

# Build at Docker build time to leverage built-in Docker caching.
WORKDIR /repo
ADD . .
RUN poetry2setup > setup.py
RUN python$PYTHON_VERSION setup.py build bdist_wheel
