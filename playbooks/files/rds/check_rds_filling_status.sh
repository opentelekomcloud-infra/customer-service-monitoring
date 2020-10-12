#!/usr/bin/env bash
run_option=$1
source=$2
pg_host=$3
pg_port=$4
pg_username=$5
pg_password=$6
drivername=$7
pg_database=$8
RDS_FILLING_PID="/tmp/rds/__main__.pid"
log_file="/tmp/rds/rds_logs.log"

if pgrep -F "$RDS_FILLING_PID" >/dev/null
then
    echo "rds filling script is running"
elif [[ $(grep -c -i "error" ${log_file}) -gt 0 || $(grep -c -i "Script finished" ${log_file}) -eq 0 ]]
then
    start-stop-daemon -Sbmvp "$RDS_FILLING_PID" -x /usr/bin/python3 /tmp/rds/__main__.py -- `
     `--run_option ${run_option} `
     `--source ${source} `
     `--host ${pg_host} `
     `--port ${pg_port} `
     `--username ${pg_username} `
     `--password ${pg_password} `
     `--database ${pg_database} `
     `--drivername ${drivername}
    echo "rds filling script is restarted"
else
    echo "rds filling script finished"
fi
