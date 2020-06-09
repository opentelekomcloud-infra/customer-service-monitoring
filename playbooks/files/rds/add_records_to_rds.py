#!/usr/bin/env python3
import psycopg2
from contextlib import closing
from argparse import ArgumentParser


def _parse_param():
    parser = ArgumentParser(description = 'Get data for connection string')
    parser.add_argument('--host', required = True)
    parser.add_argument('--port', required = True)
    parser.add_argument('--database', '-db', required = True)
    parser.add_argument('--username', '-user', required = True)
    parser.add_argument('--password', '-pass', required = True)
    args = parser.parse_args()
    return args


def _create_connection_dict() -> dict:
    """Create connection to database"""
    args = _parse_param()
    db_connect = {
        'host': args.host,
        'port': args.port,
        'user': args.username,
        'password': args.password,
        'database': args.database
    }
    return db_connect


def _sql_command(command) -> str:
    """Create sql command"""
    _command = command
    return _command


def execute_sql(sql_command: str = None):
    connection_dict = _create_connection_dict()
    with closing(psycopg2.connect(**connection_dict)) as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql_command)
            for row in cursor:
                print(row)


if __name__ == '__main__':
    args = _parse_param()
    execute_sql("""SELECT pg_database_size('entities');""")
