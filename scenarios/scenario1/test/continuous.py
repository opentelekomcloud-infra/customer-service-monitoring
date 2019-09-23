"""Stable continuous load to of the server"""
import os
import time
from argparse import ArgumentParser

import requests
import telegraf
import wrapt

LB_TIMING = "LB_TIMING"
LB_TIMING_SRV = "SRV_TIMING_{}"


@wrapt.decorator
def report(wrapped, instance: "Client" = None, args=(), kwargs=None):
    stat = wrapped(*args, **kwargs)
    srv, time_ms = stat
    instance.t_client.metric(LB_TIMING, [time_ms])
    instance.t_client.metric(LB_TIMING_SRV.format(srv), [time_ms])
    return stat


class Client:
    _url: str
    boom_limit = 30 * 60  # 30 min

    def __init__(self, url: str, tgf_address):
        self.url = url
        host, port = tgf_address.split(":", 1)
        self.t_client = telegraf.client.TelegrafClient(host, int(port), tags={"lb": "load_balancing"})
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
