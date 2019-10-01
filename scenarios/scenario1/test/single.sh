#!/usr/bin/env bash

start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$( ./../../core/get_project_root.sh )
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
terraform init || exit $?

ws_name="single"

terraform workspace select ${ws_name} || terraform workspace new ${ws_name} || exit $?

bastion_eip="80.158.3.174"

function build() {
    cur_dir=$(pwd)
    cd ${scenario_dir}/..
    ./build.sh scenario1 -var "bastion_eip=${bastion_eip}"
    cd ${cur_dir}
}

function destroy() {
    terraform destroy --auto-approve
}

function start_stop_rand_node() {
    if [[ $1 == "stop" ]]; then
        playbook=scenario1_stop_server_on_random_node.yml
    else
        playbook=scenario1_setup.yml
    fi
    cur_dir=$( pwd )
    cd ${project_root}
    ansible-playbook -i inventory/prod playbooks/${playbook}
    cd ${cur_dir}
}

function telegraf_report() {
    result=$1
    reason=$2
    public_ip="$( curl http://ipecho.net/plain -s )"
    infl_row="lb_down_test,client=${public_ip},reason=${reason} state=${result} $(date +%s%N)"
    status_code=$( curl -X -o /dev/null -q POST https://csm.outcatcher.com/telegraf -d ${infl_row} -w "%{http_code}" )
    if [[ status_code != 204 ]]; then
        echo "Can't report status to telegraf"
        exit 3
    fi
}

archive=lb_test.tgz
file_name=load_balancer_test
alias start_test="./${file_name} ${bastion_eip}"
wget -O ${archive} https://github.com/opentelekomcloud-infra/csm-test-utils/releases/download/v0.1/lb_test-0.1-linux.tar.gz
tar xf ${archive}

destroy  # cleanup if previous infra still exists
build
start_test || telegraf_report fail $? && exit 1

start_stop_rand_node stop
start_test
test_result=$?
if [[ ${test_result} == 0 ]]; then
    telegraf_report fail multiple_nodes
    exit ${test_result}
elif [[ ${test_result} != 101 ]]; then
    telegraf_report fail ${test_result}
    exit ${test_result}
fi

start_stop_rand_node start
start_test || telegraf_report fail $? && exit 1
telegraf_report pass 0
destroy
