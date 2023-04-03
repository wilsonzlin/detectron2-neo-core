# detectron2-neo

This is a fork of [Detectron2](https://github.com/facebookresearch/detectron2).

- Supports up to NVIDIA Ampere GPU arch, PyTorch 2.0, and Python 3.11.
- Uses modern Poetry for dependency management and packaging.
- Removes everything outside the core library.
- Generates prebuilt wheels for Linux x86-64.

CUDA 11.7 is used for PyTorch as it's the CUDA version marked as stable by the official [PyTorch Release Compatibility Matrix](https://pytorch.org/blog/deprecation-cuda-python-support/), and doesn't require using an extra Python index source or a different package to the official PyPI `torch`.

The package is still named `detectron2`:

```python
from detectron2.structures.boxes import Boxes

boxes = Boxes()
```

## Getting started

- You do not need to have CUDA Toolkit or cuDNN installed, and any existing installations (including different versions) won't conflict with PyTorch, as it comes with its own copy.[^1] [^2] [^3]
- Install the wheel at https://static.wilsonl.in/detectron2-neo/detectron2_neo-0.7.0-cp311-cp311-linux_x86_64.whl.
- This package is not published to PyPI as that would require building for manylinux, which is more difficult with CUDA native extensions.

## Differences to upstream

- Packages are only available for one CUDA version. There are no CPU-only variants.
- Tests and style checkers/formatters have been removed. This cleans up our fork and makes it easier to grok. We assume upstream code is correct and never change any core code in our fork.
- Sample configs, datasets, demos, models, and projects have been removed. This simplifies the fork scope to only the core library.
- Docs and READMEs have been pruned. They can still be found in the upstream unchanged.
- The minimum supported version of Python is now 3.8.
- Dependencies have been updated and pruned.
- The source tree has moved to `src` to use the [src layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).

[^1]: https://discuss.pytorch.org/t/how-to-check-if-torch-uses-cudnn/21933/5
[^2]: https://discuss.pytorch.org/t/is-cuda-back-compatible/76872/4
[^3]: https://discuss.pytorch.org/t/would-pytorch-for-cuda-11-6-work-when-cuda-is-actually-12-0/169569/2
