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
from influx_line_protocol import Metric, MetricCollection
from ocomone.logging import setup_logger
from requests import Timeout

LB_TIMING = "lb_timing"
LB_TIMEOUT = "lb_timeout"

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)

RE_URL = re.compile(r"^https?://.+$")


class Client:
    """Test client"""

    def __init__(self, url: str, tgf_address):

        if RE_URL.fullmatch(url) is None:
            url = f"http://{url}"
        self.url = url

        try:
            public_ip = requests.get("http://ipecho.net/plain", timeout=2).text
        except Timeout:
            public_ip = ""

        self.client = public_ip or socket.gethostname()
        self._tgf_address = tgf_address
        self._next_boom = 0

    def report_metric(self, metrics: MetricCollection):
        """Report metric to the server in new thread"""

        def _post_data():
            res = requests.post(f"{self._tgf_address}/telegraf", data=str(metrics), timeout=2)
            assert res.status_code == 204, f"Status is {res.status_code}"

        Thread(target=_post_data).start()

    def get(self):
        """Send request and write metrics to telegraf"""
        timeout = 20
        metrics = MetricCollection()

        try:
            res = requests.get(self.url, headers={"Connection": "close"}, timeout=timeout)
        except Timeout:
            LOGGER.exception("Timeout sending request to LB")
            lb_timeout = Metric(LB_TIMEOUT)
            lb_timeout.add_tag("client", self.client)
            lb_timeout.add_value("timeout", timeout * 1000)
            metrics.append(lb_timeout)
        else:
            lb_timing = Metric(LB_TIMING)
            lb_timing.add_tag("client", self.client)
            lb_timing.add_tag("server", res.headers["Server"])
            lb_timing.add_value("elapsed", res.elapsed.microseconds / 1000)
            metrics.append(lb_timing)

        self.report_metric(metrics)

    def run(self):
        LOGGER.info(f"Started monitoring of {self.url} (telegraf at {self._tgf_address})")
        while True:
            try:
                self.get()
                time.sleep(0.5)
            except KeyboardInterrupt:
                LOGGER.info("Monitoring Stopped")
                sys.exit(0)


def add_common_arguments(agp: ArgumentParser):
    agp.add_argument("target", help="Load balancer address")
    tgf_default = os.getenv("TGF_ADDRESS", "")
    agp.add_argument("--telegraf", help=f"Address of telegraf server for reporting. "
                                        f"Default is taken from TGF_ADDRESS variable ('{tgf_default}')",
                     default=tgf_default)
    agp.add_argument("--log-dir", "-l", help="Directory to write log file to", default=".")


if __name__ == '__main__':
    AGP = ArgumentParser(description="Script for monitor response times and nodes, reporting results to telegraf.")
    add_common_arguments(AGP)
    args = AGP.parse_args()
    setup_logger(LOGGER, "continuous", log_dir=args.log_dir, log_format="[%(asctime)s] %(message)s")
    Client(args.target, args.telegraf).run()
