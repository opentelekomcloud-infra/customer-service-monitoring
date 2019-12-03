#!/usr/bin/env bash
# This script starts continuous monitoring of load balancer nodes

start_dir=$(pwd)
local_dir=$(
    cd $(dirname "$0")
    pwd
)
project_root=$1
echo "Project root: ${project_root}"

scenario_dir=$(
    cd "${local_dir}/.."
    pwd
)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
terraform init || exit $?
terraform workspace select default
source ./post_build.sh

cd "${project_root}" || exit 1

log_path="/var/log/scenario1"

sudo mkdir -p ${log_path}
username=$(whoami)
sudo chown ${username} ${log_path}

function run_test() {
    echo "Logs will be written to ${log_path}"
    python -m csm_test_utils monitor --target "${LOADBALANCER_PUBLIC_IP}" --telegraf "http://${BASTION_PUBLIC_IP}" --log-dir ${log_path}
}

run_test >/dev/null &
bg_pid=$!
wait_end=$(($(date +%s) + 20))
while [[ $(date) < ${wait_end} ]]; do # if monitoring is dead in 20 seconds - consider test stage failed
    kill -0 ${bg_pid} || exit $?
    sleep 1s
done
