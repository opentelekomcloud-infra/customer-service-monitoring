#!/bin/bash
ip_client = $1
result=$(iperf -c $ip_client -b)
echo $result

