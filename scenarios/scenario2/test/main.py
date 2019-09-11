"""Check if server is working"""

import random
import string
import sys

from ocomone.session import BaseUrlSession


def _rand_str():
    return "".join(random.choice(string.ascii_letters) for _ in range(10))


def check_server(base_url):
    """Validate if server works correctly"""
    session = BaseUrlSession(base_url)

    data = {"data": _rand_str()}
    response = session.post("/entity", json=data, timeout=2)
    assert response.status_code == 201, f"Actual status code is {response.status_code}"
    entity_location = response.headers["Location"]

    entity = session.get(entity_location)
    assert entity.status_code == 200, f"Actual status code is {response.status_code}"
    assert entity.json() == data


if __name__ == '__main__':
    check_server(f"http://{sys.argv[1]}:80/")
