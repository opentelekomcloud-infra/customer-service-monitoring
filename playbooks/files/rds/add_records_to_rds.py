#!/usr/bin/env python3
import psycopg2
from contextlib import closing
from argparse import ArgumentParser


def _parse_param():
    parser = ArgumentParser(description = 'Get data for connection string')
    parser.add_argument('--db_url', '-url', required = True)
    parser.add_argument('--database', '-db', required = True)
    parser.add_argument('--username', '-user', required = True)
    parser.add_argument('--password', '-pass', required = True)
    args = parser.parse_args()
    return args


def _create_connection_dict() -> dict:
    """Create dict for connection to database"""
    args = _parse_param()
    db_connect = {
        'host': args.db_url,
        'user': args.username,
        'password': args.password,
        'database': args.database
    }
    return db_connect


def _sql_command(command: str = None) -> str:
    """Create sql command"""
    _command = r'{}'.format(command)
    return _command


def execute_sql(sql_command: str = None):
    _connection_dict = _create_connection_dict()
    with closing(psycopg2.connect(_connection_dict)) as conn:
        with conn.cursor() as cursor:
            cursor.execute("""SELECT pg_database_size('current_database()');""")
            for row in cursor:
                print(row)


if __name__ == '__main__':
    execute_sql()
