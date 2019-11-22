#!/usr/bin/env bash
# This works only for Debian

/sbin/start-stop-daemon -bmSp /tmp/scenario1_5.pid --exec /bin/bash -- "$(pwd)/single.sh"
