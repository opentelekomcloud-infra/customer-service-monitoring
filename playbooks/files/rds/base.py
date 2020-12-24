import logging


def logging_configuration():
    """Basic configuration for logging"""
    return logging.basicConfig(
        filename='tmp/rds/rds_logs.log',
        filemode='w',
        level=logging.DEBUG,
        format='%(levelname)s:%(asctime)s:%(message)s')


class BaseDB:
    """Base database class"""

    def __init__(self, connection: dict):
        self.connection = connection

    def _execute_sql(self, sql_query):
        raise NotImplementedError

    def get_database_size(self, db_name: str) -> int:
        raise NotImplementedError

    def is_database_fulfilled(self, db_name: str, db_max_size: int) -> bool:
        """Check if database size is more than maximum size"""
        return self.get_database_size(db_name) >= db_max_size

    def run_test(self, src_file: str):
        raise NotImplementedError
