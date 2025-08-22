from Cython.Compiler import Options
from setuptools import Extension, setup
from Cython.Build import cythonize
import sys
import platform
import numpy as np

iswindows = "win" in platform.platform().lower()
name = "uiev"

Options.docstrings = True
Options.embed_pos_in_docstring = False
Options.generate_cleanup_code = False
Options.clear_to_none = True
Options.annotate = True
Options.fast_fail = False
Options.warning_errors = False
Options.error_on_unknown_names = True
Options.error_on_uninitialized = True
Options.convert_range = True
Options.cache_builtins = True

# Makes sense on Windows?!?!
if iswindows:
    Options.gcc_branch_hints = False
else:
    Options.gcc_branch_hints = True
Options.lookup_module_cpdef = False
Options.embed = False
Options.cimport_from_pyx = True
Options.buffer_max_dims = 8
Options.closure_freelist_size = 8


configdict = {
    "py_limited_api": False,
    "name": name,
    "sources": [
        name + ".pyx",
    ],
    "include_dirs": [
        np.get_include(),
    ],
    "define_macros": [
    ],
    "undef_macros": [],
    "library_dirs": [],
    "libraries": [],
    "runtime_library_dirs": [],
    "extra_objects": [],
    "extra_compile_args": [
    ],
    "extra_link_args": [],
    "export_symbols": [],
    "swig_opts": [],
    "depends": [],
    "language": "c++",
    "optional": None,
}
compiler_directives = {
    "binding": True,  # True for more speed
    "boundscheck": False,  # False for more speed
    "wraparound": False,  # False for more speed
    "initializedcheck": False,  # False for more speed
    "nonecheck": False,  # False for more speed
    "overflowcheck": False,  # False for more speed
    "overflowcheck.fold": True,
    "embedsignature": True,
    "embedsignature.format": "c",  # (c / python / clinic)
    "cdivision": True,
    "cdivision_warnings": True,
    "cpow": True,
    "always_allow_keywords": True,  # False for a little more speed, but no keywords!!
    "c_api_binop_methods": False,
    "profile": False,
    "linetrace": False,  # False for more speed
    "infer_types": True,
    "language_level": 3,  # (2/3/3str)
    "c_string_type": "bytes",  # (bytes / str / unicode)
    "c_string_encoding": "ascii",  # (ascii, default, utf-8, etc.)
    "type_version_tag": False,
    "unraisable_tracebacks": True,
    "iterable_coroutine": True,
    "annotation_typing": True,
    "emit_code_comments": True,
    "cpp_locals": False,
    "legacy_implicit_noexcept": False,
    "optimize.use_switch": True,
    "optimize.unpack_method_calls": True,  # False for smaller file
    "warn.undeclared": True,  # (default False)
    "warn.unreachable": True,  # (default True)
    "warn.maybe_uninitialized": True,  # (default False)
    "warn.unused": True,  # (default False)
    "warn.unused_arg": True,  # (default False)
    "warn.unused_result": True,  # (default False)
    "warn.multiple_declarators": True,  # (default True)
    "show_performance_hints": True,  # (default True)
}

ext_modules = Extension(**configdict)

setup(
    name=name,
    ext_modules=cythonize(ext_modules, compiler_directives=compiler_directives),
)
sys.exit(0)
