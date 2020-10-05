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


def main():
    AGP = ArgumentParser(prog="cpu load generator ",
                         description="Generates a set of subsequent CPU utilization levels read from a file.")
    AGP.add_argument("--interval", help="interval between subsequent CPU utilization levels in seconds", default=60,
                     type=int)
    AGP.add_argument("--source", help="source file containing a new line separated list of CPU utilization levels"
                                      "specified as numbers in the [0, 100] range")
    AGP.add_argument("--ncpus", help="number of CPU cores to utilize [default: 1]", default=1)
    args, _ = AGP.parse_known_args()

    try:
        int(args.interval)
    except ValueError:
        LOGGER.error("interval must be an integer >= 0")
        sys.exit(0)

    if args.interval <= 0:
        LOGGER.error("interval must be >= 0")

    utilization = []
    with open(args.source, 'r') as file:
        levels = file.read().splitlines()
    for line in levels:
        if line.strip():
            if 0 <= int(line) <= 100:
                utilization.append(line)
            else:
                LOGGER.error("the source file must only contain new line separated numbers in the [0, 100] range")
    while True:
        try:
            process(args.interval, utilization, args.ncpus)
        except KeyboardInterrupt:
            LOGGER.info("Script Stopped")
            sys.exit(0)


if __name__ == '__main__':
    main()
