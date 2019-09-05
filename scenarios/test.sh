#!/usr/bin/env bash

scenario_name=$1

function get_value() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}

project_root=$(bash ./core/get_project_root.sh)
scenario_dir="${project_root}/scenarios/${scenario_name}"
cd ${scenario_dir} || exit 1
output="$( terraform show | grep "out-" )"

python3 test/main.py
