"""Check if server is working"""

import random
import string
import sys
from time import sleep

from ocomone.session import BaseUrlSession


def _rand_str():
    return "".join(random.choice(string.ascii_letters) for _ in range(10))


def check_loadbalance(base_url):
    session = BaseUrlSession(base_url)

    response = session.get("/", timeout=2)
    assert response.status_code == 200, f"Actual status code is {response.status_code}"
    first_request = response.headers["Server"]

    response = session.get("/", timeout=2)
    assert response.status_code == 200, f"Actual status code is {response.status_code}"
    second_request = response.headers["Server"]
    assert first_request != second_request, f"Requests Load balanced by ROUND ROBIN"

if __name__ == '__main__':
    check_loadbalance(f"http://{sys.argv[1]}:80/")
