#!/usr/bin/env bash
res="$(tgtadm --mode conn --op show --tid 1)"
data=$(echo $res | grep -oE "\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b")
MEASUREMENT="iscsi_connection"
if [[ ! -z ${data} ]];
then
  echo $MEASUREMENT,tgt_host=$(hostname),status=\"Connected\" result=1 address=$data
else
  echo $MEASUREMENT,tgt_host=$(hostname),status=\"Connection lost\" result 0
fi
