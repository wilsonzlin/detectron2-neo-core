# detectron2-neo

This is a fork of [Detectron2](https://github.com/facebookresearch/detectron2).

- Supports up to NVIDIA Ampere GPU arch, PyTorch 2.0, and Python 3.11.
- Uses modern Poetry for dependency management and packaging.
- Removes everything outside the core library.
- Generates prebuilt wheels for Linux x86-64.

CUDA 11.7 is used for PyTorch as it's the CUDA version marked as stable by the official [PyTorch Release Compatibility Matrix](https://pytorch.org/blog/deprecation-cuda-python-support/), and doesn't require using an extra Python index source or a different package to the official PyPI `torch`.

## Getting started

- You do not need to have CUDA toolkit installed, and any existing installation won't conflict with PyTorch, as it comes with its own copy.
- Install `detectron2-neo` from PyPI.

## Differences to upstream

- Packages are only available for one CUDA version. There are no CPU-only variants.
- Tests and style checkers/formatters have been removed. This cleans up our fork and makes it easier to grok. We assume upstream code is correct and never change any core code in our fork.
- Sample configs, datasets, demos, models, and projects have been removed. This simplifies the fork scope to only the core library.
- Docs and READMEs have been pruned. They can still be found in the upstream unchanged.
- The minimum supported version of Python is now 3.8.
- Dependencies have been updated and pruned.
- The source tree has moved to `src` to use the [src layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).
