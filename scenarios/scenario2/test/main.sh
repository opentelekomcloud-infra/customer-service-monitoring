#!/usr/bin/env bash

start_dir=$( pwd )
local_dir=$( dirname "$0" )
project_root=$2
echo "Project root: ${project_root}"

cd "${local_dir}/.."
echo "Local directory: $(pwd)"
output="$(terraform output)"

cd "${project_root}" || exit 1
function get_value() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}
server_ip=$( get_value "scn2_public_ip" )

function run_test() {
    poetry run python ${local_dir}/main.py "${server_ip}"
}

run_test || exit $?

cd ${project_root}
ansible-playbook -i "inventory/prod" "playbooks/scenario2_server_stop.yml"

run_test
if [[ $? == 0 ]]; then
    echo "Server wasn't killed by ansible. Something gone wrong."
    exit 2
fi

ansible-playbook -i "inventory/prod" "playbooks/scenario2_server_start.yml"
run_test || exit $?

cd ${start_dir}
exit
