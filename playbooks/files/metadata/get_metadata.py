#!/usr/bin/env python3
import re
import socket
from time import sleep

import requests
import statsd
import yaml

METADATA_URL = 'http://169.254.169.254/openstack'
DEFAULT_AZ = 'default'


def main():
    with open('get_metadata.yaml') as file:
        args = yaml.safe_load(file)
    client = statsd.StatsClient(args["host"], args["port"])
    metric_name = f'{args["statsd_prefix"]}.{args["metric_name"]}'
    try:
        az = re.search(r'eu-de-\d+', socket.gethostname()).group()
    except AttributeError:
        az = DEFAULT_AZ
    while True:
        try:
            res = requests.get(METADATA_URL, headers={'Connection': 'close'}, timeout=5)
            elapsed = res.elapsed.total_seconds() * 1000
            client.timing(f'{metric_name}.{res.status_code}.{az}', elapsed)
        except Exception as ex:
            client.incr(f'counters.{metric_name}.failed', 10)
            print(f'{socket.gethostname()} caused {ex} by invalid response')
        sleep(60)


if __name__ == '__main__':
    main()
