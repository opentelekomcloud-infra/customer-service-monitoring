""" A tool for generating a set of subsequent CPU utilization levels."""
import logging
import subprocess
import sys
import time
from argparse import ArgumentParser

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)


def process(interval, utilization_list, ncpus):
    for utilization in utilization_list:
        print(f"\nSwitching to {utilization}%")
        proc = subprocess.Popen(["lookbusy",
                                 "--ncpus", str(ncpus),
                                 "--cpu-util", utilization])
        time.sleep(interval)
        proc.terminate()


def _parse_args():
    agp = ArgumentParser(
        prog="cpu load generator ",
        description="Generates a set of subsequent CPU utilization levels read from a file.")
    agp.add_argument("--interval",
                     help="interval between subsequent CPU utilization levels in seconds",
                     default=60,
                     type=int)
    agp.add_argument("--source",
                     help="source file containing a new line separated list of CPU"
                          "utilization levels specified as numbers in the [0, 100] range")
    agp.add_argument("--ncpus",
                     help="number of CPU cores to utilize [default: 1]", default=1)
    args, _ = agp.parse_known_args()

    try:
        int(args.interval)
    except ValueError:
        LOGGER.error("interval must be an integer >= 0")
        sys.exit(1)

    if args.interval <= 0:
        LOGGER.error("interval must be >= 0")
        sys.exit(1)

    return args


def _parse_config(source: str):
    utilization = []
    with open(source, 'r') as file:
        levels = file.read().splitlines()
    for line in levels:
        if not line.isdigit():
            continue
        if 0 <= int(line) <= 100:
            utilization.append(line)
        else:
            LOGGER.error("the source file must only contain new line separated"
                         "numbers in the [0, 100] range")
    return utilization


def main():
    args = _parse_args()
    utilization = _parse_config(args.source)

    while True:
        try:
            process(args.interval, utilization, args.ncpus)
        except KeyboardInterrupt:
            LOGGER.info("Script Stopped")
            sys.exit(0)


if __name__ == '__main__':
    main()
