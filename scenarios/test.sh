#!/usr/bin/env bash

scenario_name=$1

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

project_root=$(bash ./core/get_project_root.sh)
cd ${project_root}

if [[ ! -d ".venv" ]]; then
    python3 -m venv .venv || exit 3
fi
source .venv/bin/activate


scenario_dir="${project_root}/scenarios/${scenario_name}"
cd ${scenario_dir} || exit 1

bash ./test/main.sh "${project_root}"
