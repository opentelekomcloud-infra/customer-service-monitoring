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
    poetry run python ${local_dir}/main.py "${LOADBALANCER_PUBLIC_IP}"
}

run_test || exit $?