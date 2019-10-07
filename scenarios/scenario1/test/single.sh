#!/usr/bin/env bash

start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$( bash ${local_dir}/../../core/get_project_root.sh )
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
terraform init || exit $?

ws_name="single"

terraform workspace select ${ws_name} || terraform workspace new ${ws_name} || exit $?

function start_stop_rand_node() {
    if [[ "$1" == "stop" ]]; then
        playbook=scenario1_stop_server_on_random_node.yml
    else
        playbook=scenario1_setup.yml
    fi
    cur_dir=$( pwd )
    cd ${project_root}
    ansible-playbook -i inventory/prod playbooks/${playbook}
    cd ${cur_dir}
    sleep 3s
}

function prepare() {
    cur_dir=$(pwd)
    cd ${scenario_dir}
    bash ./pre_build.sh
    file=tmp_state
    terraform state pull > ${file} || exit $?
    source "${project_root}/.venv/bin/activate"
    export PYTHONPATH="${PYTHONPATH}:${scenario_dir}/test"
    python3 "${project_root}/scenarios/core/create_inventory.py" ${file} --name "scenario1-single"
    source ./post_build.sh
    start_stop_rand_node start  # check that all nodes are running before test
    cd ${cur_dir}
}

csm_host="https://csm.outcatcher.com"
telegraf="${csm_host}/telegraf"

function telegraf_report() {
    result=$1
    reason=$2
    echo Report result: ${result}\(${reason}\)
    public_ip="$( curl http://ipecho.net/plain -s )"
    infl_row="lb_down_test,client=${public_ip},reason=${reason} state=\"${result}\""
    status_code=$( curl -q -o /dev/null -X POST ${telegraf} -d "${infl_row}" -w "%{http_code}" )
    if [[ "${status_code}" != "204" ]]; then
        echo "Can't report status to telegraf ($status_code)"
        exit 3
    fi
}

version=0.1
archive=lb_test-${version}.tgz
if [[ ! -e ${archive} ]]; then
    wget -q -O ${archive} https://github.com/opentelekomcloud-infra/csm-test-utils/releases/download/v${version}/lb_test-${version}-linux.tar.gz
    tar xf ${archive}
fi

prepare
echo Preparation Finished
lb_host="ecs-80-158-23-240.reverse.open-telekom-cloud.com"
echo LB at ${lb_host}
start_test="./load_balancer_test ${lb_host} 300"
echo Starting test...

function test_should_pass() {
    res=$?
    if [[ ${res} != 0 ]]; then
        telegraf_report fail ${res}
        echo Test failed
        exit ${res}
    fi
    echo Test passed
}

${start_test}
test_should_pass

start_stop_rand_node stop
${start_test}
test_result=$?
if [[ ${test_result} == 0 ]]; then
    telegraf_report fail multiple_nodes
    exit ${test_result}
elif [[ ${test_result} != 101 ]]; then
    telegraf_report fail ${test_result}
    exit ${test_result}
fi
python "${scenario_dir}/test/rebalance_test.py" ${lb_host} --telegraf=${csm_host} || exit $?  # check that LB excludes not working node in some time

start_stop_rand_node start
python "${scenario_dir}/test/rebalance_test.py" ${lb_host} --telegraf=${csm_host} --nodes 2 || exit $?  # check that LB excludes not working node in some time

${start_test}
test_should_pass
telegraf_report pass 0
deactivate
