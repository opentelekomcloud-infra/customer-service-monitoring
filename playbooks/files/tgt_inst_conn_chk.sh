#!/usr/bin/env bash
telegraf="localhost:8080"
res="$(tgtadm --mode conn --op show --tid 1)"
data=$(echo $res | grep -oE "\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b")
if [[ ! -z ${data} ]];
then
  telegraf_report connected ok
else
  telegraf_report connection_lost fail
fi

function telegraf_report() {
    result=$1
    reason=$2
    MEASUREMENT="iscsi_connection"
    infl_row="${MEASUREMENT},tgt_host=$(hostname),reason=${reason} state=\"${result}\""
    status_code=$( curl -q -o /dev/null -X POST ${telegraf} -d "${infl_row}" -w "%{http_code}" )
    if [[ "${status_code}" != "204" ]]; then
        echo "Can't report status to telegraf ($status_code)"
        exit 3
    fi
}