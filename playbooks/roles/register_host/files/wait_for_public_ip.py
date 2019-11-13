#!/usr/bin/env python
"""Check availability with given public ip on port 22"""
import socket
import sys


def main(ip, timeout):
    """Try to connect to """
    sock = socket.socket()
    sock.settimeout(timeout)
    sock.connect((ip, 22))


if __name__ == '__main__':
    print("Arguments provided: ", sys.argv)
    if len(sys.argv) == 1:
        raise AttributeError("No positional arguments given to wait script")
    address = sys.argv[1]
    timeout_seconds = 120
    if len(sys.argv) > 2 and sys.argv[2].isdigit():
        timeout_seconds = int(sys.argv[2])
    main(address, timeout_seconds)
