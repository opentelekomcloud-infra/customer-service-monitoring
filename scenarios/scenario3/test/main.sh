#!/usr/bin/env bash
start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$1
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
# source ./pre_build.sh

cd "${project_root}" || exit 1

function run_test() {
    python "${local_dir}/main.py"  # <arguments>
}

cd ${start_dir}
