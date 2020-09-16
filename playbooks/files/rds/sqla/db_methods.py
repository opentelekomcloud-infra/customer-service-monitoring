import logging
import string
import random
import yaml
import os

from contextlib import closing
from psycopg2 import Error
from sqlalchemy import engine

from arg_parser import get_source
from .db_model import TestRdsTable
from .session import get_db_engine, get_session


def _logging_configuration():
    """Basic configuration for logging"""
    return logging.basicConfig(
        filename = 'rds_logs.log',
        filemode = 'w',
        level = logging.DEBUG,
        format='%(levelname)s:%(asctime)s:%(message)s')


def _random_str_generation(size) -> str:
    """Generate random string which consist of letters and digits."""
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(size))


def _execute_sql(sqla_engine: engine, sql_query: str):
    """Execute sql command which depends on db dialect"""
    try:
        with closing(sqla_engine.connect()) as connection:
            result = connection.execute(sql_query).fetchall()
    except Error as e:
        logging.error('Error occured', exc_info = True)
    return result


def get_database_size(sqla_engine: engine) -> int:
    """Get size of current database that returns in bytes"""
    return _execute_sql(sqla_engine, "select pg_database_size(current_database());")[0][0]


def is_database_fulfilled(sqla_engine: engine, db_max_size: int) -> bool:
    """Check database size and return false if database size is not enough"""
    return get_database_size(sqla_engine) >= db_max_size


def main():
    _logging_configuration()
    sqla_engine = get_db_engine()
    data_source = get_source()
    session = get_session(sqla_engine)
    logging.info('Scripts starts')
    with open(data_source) as data_file:
        data = yaml.safe_load(data_file)
        content_str = _random_str_generation(data['symbol_count'])
        while not is_database_fulfilled(sqla_engine, data['max_size_in_bytes']):
            TestRdsTable.metadata.create_all(sqla_engine)
            session.add_all([TestRdsTable(content_str + str(i)) for i in range(data['record_count'])])
            session.commit()
            logging.info('Commit session')
        session.close_all()
    logging.info('Script finished')


if __name__ == "__main__":
    main()
