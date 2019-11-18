#!/usr/bin/env bash

scenario_name=$1

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

project_root=$(bash ./core/get_project_root.sh)
cd ${project_root}
venv="${project_root}/.venv"
python3 -c "import sys; sys.exit(not sys.version_info >= (3, 7))" || (echo "Python version is too low, 3.7+ expected" && exit 1)
if [[ ! -d ${venv} ]]; then
    python3 -m venv ${venv} || exit 3
fi
source ${venv}/bin/activate
python -m pip install -r "${project_root}/playbooks/files/requirements.txt" || ( echo "can't activate venv" && exit 3 )


scenario_dir="${project_root}/scenarios/${scenario_name}"
cd ${scenario_dir} || exit 1

test_path="./test/main.sh"

if [[ ! -e ${test_path} ]]; then
    echo "No test script exists for scenario ${scenario_name}"
    exit 0
fi

echo "Starting test"
bash ${test_path} "${project_root}"
