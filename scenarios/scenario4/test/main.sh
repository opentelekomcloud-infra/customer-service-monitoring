#!/usr/bin/env bash
# This is script starting continuous monitoring of load balancer nodes

start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$1
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
terraform init || exit $?
terraform workspace select default
source ./post_build.sh

cd "${project_root}" || exit 1

log_path="/var/log/scenario4"

sudo mkdir -p ${log_path}
username=$(whoami)
sudo chown ${username} ${log_path}


function run_test() {
    echo "Logs will be written to ${log_path}"
    python -m csm_test_utils monitor --target "${LOADBALANCER_PUBLIC_IP}" --telegraf https://csm.outcatcher.com --log-dir ${log_path}
}

run_test > /dev/null &