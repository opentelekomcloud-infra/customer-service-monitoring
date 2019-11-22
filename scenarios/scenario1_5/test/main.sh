#!/usr/bin/env bash

start-stop-daemon -bmSp /tmp/scenario1_5.pid --exec /bin/bash -- "$(pwd)/single.sh"
