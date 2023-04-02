# detectron2-neo

This is a fork of [Detectron2](https://github.com/facebookresearch/detectron2).

- Supports PyTorch 2.0, Python 3.11, and CUDA 11.8.
- Uses modern Poetry for dependency management and packaging.
- Removes everything outside the core library.
- Generates prebuilt wheels for Linux x86-64.

## Differences to upstream

- Tests and style checkers/formatters have been removed. This cleans up our fork and makes it easier to grok. We assume upstream code is correct and never change any core code in our fork.
- Sample configs, datasets, demos, models, and projects have been removed. This simplifies the fork scope to only the core library.
- Docs and READMEs have been pruned. They can still be found in the upstream unchanged.
- The minimum supported version of Python is now 3.8.
- Dependencies have been updated and pruned.
- The source tree has moved to `src` to use the [src layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).
