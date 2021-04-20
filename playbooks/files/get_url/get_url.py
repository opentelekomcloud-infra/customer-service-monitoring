#!/usr/bin/env python3

from time import sleep

import requests
import statsd
import yaml


def main():
    with open('get_url.yaml') as file:
        args = yaml.safe_load(file)
    client = statsd.StatsClient(args["host"], args["port"])
    while True:
        for host in args["nodes"]:
            metric_name = f'{args["statsd_prefix"]}.{args["metric_name"]}.{host["name"]}'
            try:
                res = requests.get(host["ip"], headers={'Connection': 'close'}, timeout=5)
                client.timing(f'{metric_name}', res.elapsed.total_seconds() * 1000)
            except Exception as ex:
                client.incr(f'counters.{metric_name}.failed')
                print(f'{host["name"]} caused {ex} by invalid response')
        sleep(10)


if __name__ == '__main__':
    main()
