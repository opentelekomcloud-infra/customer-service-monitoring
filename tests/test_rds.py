import time
import unittest

import psycopg2
from docker import from_env
from docker.models.containers import Container

POSTGRES_IMAGE = 'postgres:10'
POSTGRES_ADDRESS = 'postgres:5432'


def _prepare_src_file() -> str:
    pass


class TestRDS(unittest.TestCase):
    container: Container
    common_arg_dict: dict

    @classmethod
    def _pg_wait(cls):
        connection = {
            'host': cls.common_arg_dict['host'],
            'port': cls.common_arg_dict['port'],
            'user': cls.common_arg_dict['username'],
            'password': cls.common_arg_dict['password'],
        }
        timeout = 60
        start_time = time.monotonic()
        end_time = start_time + timeout
        while time.monotonic() < end_time:
            try:
                psycopg2.connect(**connection)
            except psycopg2.OperationalError:
                time.sleep(.5)
                continue
            time_passed = time.monotonic() - start_time
            print('Postgres is up in', round(time_passed, 3), 'seconds')
            return
        raise TimeoutError(f'Postgres is not up after {timeout} seconds')

    @classmethod
    def setUpClass(cls) -> None:
        tmp_src = _prepare_src_file()
        host, port = POSTGRES_ADDRESS.split(':')
        port = int(port)
        postgres_username = 'postgres'
        postgres_password = 'Nezhachto!2020'

        cls.container = from_env().containers.run(
            POSTGRES_IMAGE,
            detach=True,
            hostname=host,
            name='postgres',
            ports={
                f'{port}/tcp': port
            },
            environment={
                'POSTGRES_USER': postgres_username,
                'POSTGRES_PASSWORD': postgres_password,
            }
        )

        cls.common_arg_dict = {
            'source': tmp_src,
            'host': 'localhost',
            'port': port,
            'username': postgres_username,
            'password': postgres_password
        }

        cls._pg_wait()

    @classmethod
    def tearDownClass(cls) -> None:
        cls.container.remove(force=True)

    def test_SQL_alchemy(self):
        alchemy_args = {'run_option': 'sqla', **self.common_arg_dict}

    def test_pg2(self):
        pg2_args = {'run_option': 'pg2', **self.common_arg_dict}
