"""Check if server is working"""

import json
import random
import string
import subprocess

from ocomone import Resources
from ocomone.session import BaseUrlSession

SCENARIO_ROOT = Resources(__file__, "./..")


def _get_output_value(state, key):
    return state["outputs"][f"out-{key}"]["value"]


def _rand_str():
    return "".join(random.choice(string.ascii_letters) for _ in range(10))


def check_server(base_url):
    """Validate if server works correctly"""
    session = BaseUrlSession(base_url)

    data = {"data": _rand_str()}
    response = session.post("/entity", json=data, timeout=2)
    assert response.status_code == 201
    entity_location = response.headers["Location"]

    entity = session.get(entity_location)
    assert response.status_code == 200
    assert entity.json() == data


def main():
    done = subprocess.run("terraform state pull",
                          shell=True,
                          stdout=subprocess.PIPE,
                          universal_newlines=True,
                          cwd=SCENARIO_ROOT.resource_root)
    done.check_returncode()
    state = json.loads(done.stdout)
    server_ip = _get_output_value(state, "scn2_public_ip")
    check_server(f"http://{server_ip}:80/")


if __name__ == '__main__':
    main()
