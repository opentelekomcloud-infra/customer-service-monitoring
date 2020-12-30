#!/usr/bin/env bash
telegraf_host="http://localhost:8080"
test_folder="/home/linux/test"
telegraf="${telegraf_host}/telegraf"
load_balancer_ip=$(cat "${test_folder}/load_balancer_ip")

eval "$(ssh-agent)"
ssh-add "${test_folder}/key_csm_controller"

version=0.1
archive=lb_test-${version}.tgz
if [[ ! -e ${archive} ]]; then
  wget -q -O ${archive} https://github.com/opentelekomcloud-infra/csm-test-utils/releases/download/v${version}/lb_test-${version}-linux.tar.gz
  tar xf ${archive}
fi


echo LB at "${load_balancer_ip}"

start_test="./load_balancer_test ${load_balancer_ip} 300"

function start_stop_rand_node() {
  if [[ "$1" == "stop" ]]; then
    playbook=lb_down_monitoring_stop_server_on_random_node.yml
  else
    playbook=lb_down_monitoring_start_server.yml
  fi
  cur_dir=$(pwd)
  cd "${test_folder}" || exit 2
  ansible-playbook -i inventory/prod ${playbook} || exit 1
  cd "${cur_dir}" || exit 2
  sleep 3s
}

function telegraf_report() {
  result=$1
  reason=$2
  echo "Report result: ${result} (${reason})"

  public_ip="$(curl http://ipecho.net/plain -s)"
  influx_row="lb_down_test,client=${public_ip},reason=${reason} state=${result}"

  status_code=$(curl -q -o /dev/null -X POST ${telegraf} -d "${influx_row}" -w "%{http_code}")

  if [[ "${status_code}" != "204" ]]; then
    echo "Can't report status to telegraf ($status_code)"
    exit 3
  fi
}

echo Starting test...

function test_should_pass() {
  res=$?
  if [[ ${res} != 0 ]]; then
    telegraf_report 1 ${res}
    echo Test failed with ${res}
    exit ${res}
  fi
  telegraf_report 0 ok
  echo Test passed
}
start_stop_rand_node start # check that all nodes are running before test
${start_test}
test_should_pass

start_stop_rand_node stop
${start_test}
test_result=$?

if [[ ${test_result} == 0 ]]; then
  telegraf_report 1 multiple_nodes
  exit ${test_result}
elif [[ ${test_result} != 101 ]]; then
  telegraf_report 1 one_node
  exit ${test_result}
fi

/usr/bin/python3 -m csm_test_utils rebalance --target "${load_balancer_ip}" --telegraf "${telegraf_host}" || telegraf_report 1 $?

sleep 60 # make reports beautiful again

start_stop_rand_node start
/usr/bin/python3 -m csm_test_utils rebalance --target "${load_balancer_ip}" --telegraf "${telegraf_host}" || telegraf_report 1 $?

${start_test}
test_should_pass

pkill ssh-agent
