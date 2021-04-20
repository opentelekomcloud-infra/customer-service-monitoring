#!/usr/bin/env python3

import json
import re
import subprocess as sp
from time import sleep

import statsd
import yaml


def serialize_metric(msg):
    try:
        return json.dumps(msg, separators=(',', ':'))
    except json.JSONDecodeError as err:
        return err.msg


def main():
    with open('ping.yaml') as file:
        args = yaml.safe_load(file)
    client = statsd.StatsClient(args["host"], args["port"])
    while True:
        for host in args["nodes"]:
            metric_name = f'{args["statsd_prefix"]}.{args["metric_name"]}.{host["name"]}'
            duration = -1
            try:
                rsp = sp.check_output(
                    ['ping', '-c', '1', '-s', args["size"], host["ip"]],
                    stderr=sp.STDOUT,
                    universal_newlines=True
                )
                duration = re.search(r'time=(\d+)', rsp).group(1)
                client.timing(f'{metric_name}', float(duration))
            except Exception as ex:
                client.incr(f'counters.{metric_name}.failed')
                print(f'{host["name"]} caused {ex} by invalid response')
        sleep(5)


if __name__ == '__main__':
    main()
