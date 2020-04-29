#!/usr/bin/env bash
CPU_LOAD_PID="/tmp/cpu_load.pid"
if pgrep -F "$CPU_LOAD_PID" >/dev/null
then
    echo "cpu_load script is running"
else
    start-stop-daemon -Sbmvp /tmp/cpu_load.pid -x /usr/bin/python3 /tmp/cpu_load.py -- --source /tmp/load_levels.dat --interval 60 --ncpus 2
    echo "cpu_load script is restarted"
fi
