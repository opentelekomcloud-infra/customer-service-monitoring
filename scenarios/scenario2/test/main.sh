#!/usr/bin/env bash

start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$1
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
source ./post_build.sh

cd "${project_root}" || exit 1

function run_test() {
    python ${local_dir}/main.py "${SERVER_PUBLIC_IP}"
}

run_test || exit $?

cd ${project_root}
ansible-playbook -i "inventory/prod" "playbooks/scenario2_server_stop.yml"

run_test
if [[ $? == 0 ]]; then
    echo "Server wasn't killed by ansible. Something gone wrong."
    exit 2
fi

ansible-playbook -i "inventory/prod" "playbooks/scenario2_setup.yml"
run_test || exit $?

cd ${start_dir}
