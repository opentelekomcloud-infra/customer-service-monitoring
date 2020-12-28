import os

_BASE_PATH = os.path.abspath(os.path.dirname(__file__))


def resource_path(*file_path) -> str:
    """Get resource file absolute path for files located in resources dir"""
    return os.path.join(_BASE_PATH, 'resources', *file_path)
