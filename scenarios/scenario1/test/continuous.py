"""Stable continuous load to of the server"""
import logging
import os
import re
import socket
import sys
import time
from argparse import ArgumentParser
from threading import Thread

import requests
import wrapt
from influx_line_protocol import Metric, MetricCollection
from ocomone.logging import setup_logger
from ocomone.session import BaseUrlSession
from requests import Timeout

LB_TIMING = "lb_timing"

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)


@wrapt.decorator
def report(wrapped, instance: "Client" = None, args=(), kwargs=None):
    stat = wrapped(*args, **kwargs)
    srv, time_ms = stat
    metrics = MetricCollection()
    lb_timing = Metric(LB_TIMING)
    lb_timing.add_value("elapsed", time_ms)
    lb_timing.add_tag("server", srv)
    lb_timing.add_tag("client", instance.client)
    metrics.append(lb_timing)

    def _post_data():
        res = instance.session.post("/telegraf", data=str(metrics))
        assert res.status_code == 204, f"Status is {res.status_code}"

    Thread(target=_post_data, daemon=True).start()
    return stat


RE_URL = re.compile(r"^https?://.+$")


class Client:
    def __init__(self, url: str, tgf_address):

        if RE_URL.fullmatch(url) is None:
            url = f"http://{url}"
        self.url = url

        try:
            public_ip = requests.get("http://ipecho.net/plain", timeout=2).text
        except Timeout:
            public_ip = ""

        self.client = public_ip or socket.gethostname()
        self.session = BaseUrlSession(tgf_address)
        self._tgf_address = tgf_address
        self._next_boom = 0

    @report
    def get(self):
        """Send request and write metrics to telegraf"""
        res = requests.get(self.url, headers={"Connection": "close"})
        stat = res.headers["Server"], res.elapsed.microseconds / 1000
        return stat

    def run(self):
        LOGGER.info(f"Started monitoring of {self.url} (telegraf at {self._tgf_address})")
        while True:
            try:
                LOGGER.debug(self.get())
                time.sleep(0.5)
            except KeyboardInterrupt:
                LOGGER.info("Monitoring Stopped")
                sys.exit(0)


if __name__ == '__main__':
    AGP = ArgumentParser(description="Script for monitor response times and nodes, reporting results to telegraf.")
    AGP.add_argument("target", help="Load balancer address")
    tgf_default = os.getenv("TGF_ADDRESS", "")
    AGP.add_argument("--telegraf", help=f"Address of telegraf server for reporting. "
                                        f"Default is taken from TGF_ADDRESS variable ('{tgf_default}')",
                     default=tgf_default)
    AGP.add_argument("--log-dir", "-l", help="Directory to write log file to", default=".")
    ARGS = AGP.parse_args()
    setup_logger(LOGGER, "continuous", log_dir=ARGS.log_dir, log_format="%(message)s")
    Client(ARGS.target, ARGS.telegraf).run()
