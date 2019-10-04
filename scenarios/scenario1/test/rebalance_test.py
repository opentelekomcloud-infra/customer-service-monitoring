import time
from argparse import ArgumentParser

import requests
from influx_line_protocol import Metric, MetricCollection
from requests.exceptions import ConnectionError

from continuous import Client, add_common_arguments


def parse_args():
    agp = ArgumentParser(description="Script for monitor server downtime due to single node service dead")
    add_common_arguments(agp)
    agp.add_argument("--nodes", type=int, help="Expected number of nodes")
    args = agp.parse_args()
    return args


LB_DOWNTIME = "lb_down"


def report_failed(client: Client):
    metrics = MetricCollection()
    lb_down = Metric(LB_DOWNTIME)
    lb_down.add_value("failed_requests", 1)
    metrics.append(lb_down)
    client.report_metric(metrics)


def main():
    """Find unavailable node and waits until it won't be used"""
    args = parse_args()
    client = Client(args.target, args.telegraf)

    end_time = time.monotonic() + 3

    def _check_timeout(msg):
        if time.monotonic() > end_time:
            raise TimeoutError(msg)

    max_success_count = 15  # max number of consecutive successful requests to consider downtime finished
    success_count = 0
    timeout = 120
    end_time = time.monotonic() + timeout
    print("Started waiting for loadbalancer to re-balance nodes")
    nodes = set()
    while success_count < max_success_count:
        try:
            resp = requests.get(client.url, headers={"Connection": "close"}, timeout=1)
            if resp.status_code == 200:
                nodes.add(resp.headers["Server"])
        except ConnectionError:  # one node is down
            success_count = 0
            report_failed(client)
        else:
            success_count += 1
        finally:
            _check_timeout(f"No re-balancing is done after {timeout} seconds")
    if len(nodes) > args.nodes:
        raise AssertionError(f"Too many nodes running: {len(nodes)} instead of {args.nodes}")
    print("LB rebalanced nodes")


if __name__ == '__main__':
    main()
