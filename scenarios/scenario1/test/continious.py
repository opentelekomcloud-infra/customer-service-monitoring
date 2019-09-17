"""Stable continuous load to of the server"""
import os
import subprocess
import sys
import time

import requests

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))


def _test():
    return subprocess.run("boom", shell=True, stderr=subprocess.PIPE)


def _fail(message):
    cur_time = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())
    print(f"FAIL ({cur_time}):\n{message}")


class Client:
    _url: str
    boom_limit = 30 * 60  # 30 min

    def __init__(self, url: str):
        self.url = url
        self._next_boom = 0

    def get(self):
        res = requests.get(self.url, headers={"Connection": "close"})
        return res.headers["Server"], res.elapsed.microseconds / 1000

    @property
    def ready(self):
        return time.monotonic() > self._next_boom

    def boom(self):
        """Start/stop server, run short test"""
        self._next_boom = time.monotonic() + self.boom_limit

        # make boom here
        print("BOOM!")
        done = _test()
        if done.returncode != 0:
            _fail(done.stderr)

        subprocess.run("ansible-playbook -i inventory/prod"
                       "playbooks/scenario1_stop_server_on_random_node.yml", shell=True)
        done = _test()
        if done.returncode != 101:
            _fail("Can't stop one node")

        subprocess.run("ansible-playbook -i inventory/prod"
                       "playbooks/scenario1_setup.yml", shell=True)
        done = _test()
        if done.returncode != 0:
            print("LB test after restore failed")
            _fail(done.stderr)

    def run(self):
        while True:
            if self.ready:
                self.boom()
            print(self.get())
            time.sleep(0.5)


if __name__ == '__main__':
    Client(sys.argv[1]).run()
