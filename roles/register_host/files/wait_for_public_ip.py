#!/usr/bin/env python
"""Check availability with given public ip on port 22"""
import socket
import sys


def main():
    """Try to connect to """
    print('Arguments provided: ', sys.argv)
    if len(sys.argv) == 1:
        raise AttributeError('No positional arguments given to wait script')
    address = sys.argv[1]
    timeout_seconds = 120
    if len(sys.argv) > 2 and sys.argv[2].isdigit():
        timeout_seconds = int(sys.argv[2])

    sock = socket.socket()
    sock.settimeout(timeout_seconds)
    sock.connect((address, 22))


if __name__ == '__main__':
    main()
