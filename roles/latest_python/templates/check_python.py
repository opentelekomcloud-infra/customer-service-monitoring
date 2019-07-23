import sys

expected = tuple(int(x) for x in '{{ min_py_version }}'.split('.'))

if sys.version_info < expected:
    sys.exit(1)
