#!/usr/bin/env python3
import sys

import openstack
import logging


conn = openstack.connect()

server = conn.compute.find_server(sys.argv[1])

if server:
    metadata = server.get_metadata(conn.compute)
