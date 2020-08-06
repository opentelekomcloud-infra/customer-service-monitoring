#!/usr/bin/env bash
pg_host=$1
pg_port=$2
pg_username=$3
pg_password=$4
RDS_FILLING_PID="/tmp/add_records_to_rds.pid"
log_file="/tmp/logs.log"
if pgrep -F "$RDS_FILLING_PID" >/dev/null
then
    echo "rds filling script is running"
elif [[ $(grep -c -i "error" ${log_file}) -gt 0 || $(grep -c -i "Script finished" ${log_file}) -eq 0 ]]
then
    start-stop-daemon -Sbmvp "$RDS_FILLING_PID" -x /usr/bin/python3 /tmp/add_records_to_rds.py -- --host ${pg_host} --port ${pg_port} --username ${pg_username} --password ${pg_password} --database 'entities'
    echo "rds filling script is restarted"
else
    echo "rds filling script finished"
fi