#!/bin/bash
ip_client = $1
result=$(iperf -c $ip_client | awk 'NR==7{print $7,$8}')
echo $result

