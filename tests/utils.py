import os

PROJECT_ROOT = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        '..'
    )
)

IS_ACCEPTANCE = bool(os.getenv("CSM_ACC"))


def project_path(*file_path):
    """Path starting from project root"""
    return os.path.join(PROJECT_ROOT, *file_path)


def resource_path(*file_path) -> str:
    """Get resource file absolute path for files located in resources dir"""
    return project_path('tests', 'resources', *file_path)
