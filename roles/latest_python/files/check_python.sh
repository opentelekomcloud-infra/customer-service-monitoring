#!/usr/bin/env bash

python3 /tmp/check_python.py

state=$?

if [[ ${state} == 1 || ${state} == 127 ]]
then echo -n install
elif [[ ${state} == 0 ]]
then echo -n noinstall
else exit ${state}
fi