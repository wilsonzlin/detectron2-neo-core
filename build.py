import sys
# Poetry won't load dev deps while calling build.py, so we manually load it from default pip user and system paths. Note that this means `torch` should be installed outside of this repo as well.
# This only affects build process, and has no impact on output binary or runtime.
sys.path += (
  f"/usr/local/lib/python{'.'.join(str(v) for v in sys.version_info[:2])}/dist-packages",
)
import glob
import os
import torch
from os import path
from torch.utils.cpp_extension import CUDA_HOME, CppExtension, CUDAExtension, ROCM_HOME

torch_ver = [int(x) for x in torch.__version__.split(".")[:2]]
assert torch_ver >= [1, 8], "Requires PyTorch >= 1.8"

def get_extensions():
    this_dir = path.dirname(path.abspath(__file__))
    extensions_dir = path.join(this_dir, "src", "detectron2", "layers", "csrc")

    main_source = path.join(extensions_dir, "vision.cpp")
    sources = glob.glob(path.join(extensions_dir, "**", "*.cpp"))

    is_rocm_pytorch = (torch.version.hip is not None) and (ROCM_HOME is not None)

    # common code between cuda and rocm platforms, for hipify version [1,0,0] and later.
    source_cuda = glob.glob(path.join(extensions_dir, "**", "*.cu")) + glob.glob(
        path.join(extensions_dir, "*.cu")
    )
    sources = [main_source] + sources

    extension = CppExtension

    extra_compile_args = {"cxx": []}
    define_macros = []

    if (torch.cuda.is_available() and ((CUDA_HOME is not None) or is_rocm_pytorch)) or os.getenv(
        "FORCE_CUDA", "0"
    ) == "1":
        extension = CUDAExtension
        sources += source_cuda

        if not is_rocm_pytorch:
            define_macros += [("WITH_CUDA", None)]
            extra_compile_args["nvcc"] = [
                "-O3",
                "-DCUDA_HAS_FP16=1",
                "-D__CUDA_NO_HALF_OPERATORS__",
                "-D__CUDA_NO_HALF_CONVERSIONS__",
                "-D__CUDA_NO_HALF2_OPERATORS__",
            ]
        else:
            define_macros += [("WITH_HIP", None)]
            extra_compile_args["nvcc"] = []

    include_dirs = [extensions_dir]

    ext_modules = [
        extension(
            "detectron2._C",
            sources,
            include_dirs=include_dirs,
            define_macros=define_macros,
            extra_compile_args=extra_compile_args,
        )
    ]

    return ext_modules


def build(setup_kwargs):
    setup_kwargs.update(
        {"ext_modules": get_extensions(), "cmdclass": {"build_ext": torch.utils.cpp_extension.BuildExtension}}
    )
