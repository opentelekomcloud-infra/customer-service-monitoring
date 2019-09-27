"""Stable continuous load to of the server"""
import os
import socket
import time
from argparse import ArgumentParser
from threading import Thread

import requests
import wrapt
from influx_line_protocol import Metric, MetricCollection
from ocomone.session import BaseUrlSession

LB_TIMING = "lb_timing"


@wrapt.decorator
def report(wrapped, instance: "Client" = None, args=(), kwargs=None):
    stat = wrapped(*args, **kwargs)
    srv, time_ms = stat
    client = requests.get("http://ipecho.net/plain").text
    if client == "":
        client = socket.gethostname()
    metrics = MetricCollection()
    lb_timing = Metric(LB_TIMING)
    lb_timing.add_value("elapsed", time_ms)
    lb_timing.add_tag("server", srv)
    lb_timing.add_tag("client", client)
    metrics.append(lb_timing)

    def _post_data():
        res = instance.session.post("/telegraf", data=str(metrics))
        assert res.status_code == 204, f"Status is {res.status_code}"

    Thread(target=_post_data, daemon=True).start()
    return stat


class Client:
    _url: str
    boom_limit = 30 * 60  # 30 min

    def __init__(self, url: str, tgf_address):
        self.url = url
        self.session = BaseUrlSession(tgf_address)
        self._next_boom = 0

    @report
    def get(self):
        """Send request and write metrics to telegraf"""
        res = requests.get(self.url, headers={"Connection": "close"})
        stat = res.headers["Server"], res.elapsed.microseconds / 1000
        return stat

    def run(self):
        while True:
            print(self.get())
            time.sleep(0.5)


if __name__ == '__main__':
    AGP = ArgumentParser(description="Script for monitor response times and nodes, reporting results to telegraf.")
    AGP.add_argument("target", help="Load balancer address")
    tgf_default = os.getenv("TGF_ADDRESS", "")
    AGP.add_argument("--telegraf", help=f"Address of telegraf server for reporting. "
                                        f"Default is taken from TGF_ADDRESS variable ('{tgf_default}')",
                     default=tgf_default)
    ARGS = AGP.parse_args()
    Client(ARGS.target, ARGS.telegraf).run()
