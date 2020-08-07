#!/bin/bash
result=$(iperf -c ${1} -b)
echo $result

