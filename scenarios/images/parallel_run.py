#!/usr/bin/env python3
"""Start building images in parallel."""

import subprocess
import sys
from concurrent.futures.thread import ThreadPoolExecutor

TIMEOUT = 20 * 60


def main():
    """Run packer for all given targets in a parallel."""
    targets = sys.argv[1:]

    def _run(_target):
        subprocess.run(f"bash ./build_image.sh {target}", shell=True, timeout=TIMEOUT)

    with ThreadPoolExecutor() as executor:
        for target in targets:
            executor.submit(_run, target)


if __name__ == '__main__':
    main()
