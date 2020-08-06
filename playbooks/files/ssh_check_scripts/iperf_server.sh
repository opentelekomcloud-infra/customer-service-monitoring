#!/bin/bash
iperf -s &
sleep 10
pid=$(jobs -l | grep Running | grep iperf -s | awk '{print $2}')
kill $pid
exit 0
