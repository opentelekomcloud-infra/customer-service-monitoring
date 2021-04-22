#!/usr/bin/env python3
import socket
from time import sleep

import requests
import statsd
import yaml


def main():
    with open('get_metadata.yaml') as file:
        args = yaml.safe_load(file)
    client = statsd.StatsClient(args["host"], args["port"])
    while True:
        metric_name = args["metric_name"]
        metric_name = f'{args["statsd_prefix"]}.{args["metric_name"]}.{socket.gethostname()}'
        try:
            res = requests.get('http://169.254.169.254/openstack', headers={'Connection': 'close'}, timeout=5)
            client.timing(f'{metric_name}.{res.status_code}', res.elapsed.total_seconds() * 1000)
        except Exception as ex:
            client.incr(f'counters.{metric_name}.failed', 10)
            print(f'{socket.gethostname()} caused {ex} by invalid response')
        sleep(60)


if __name__ == '__main__':
    main()
