import time
from argparse import ArgumentParser

import requests
from continuous import Client, add_common_arguments
from influx_line_protocol import Metric, MetricCollection


def parse_args():
    agp = ArgumentParser(description="Script for monitor server downtime due to single node service dead")
    add_common_arguments(agp)
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
    while success_count < max_success_count:
        try:
            requests.get(client.url, headers={"Connection": "close"}, timeout=1)
        except ConnectionRefusedError:  # one node is down
            success_count = 0
            report_failed(client)
            _check_timeout(f"No re-balancing is done after {timeout} seconds")
        else:
            success_count += 1
    print("LB rebalanced nodes")


if __name__ == '__main__':
    main()
