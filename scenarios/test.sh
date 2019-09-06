#!/usr/bin/env bash

scenario_name=$1

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

project_root=$(bash ./core/get_project_root.sh)

# prepare virtual environment
poetry --version > /dev/null
if [[ $? != 0 ]]; then
    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
fi
cd ${project_root}
poetry install
poetry run python --version
# end venv preparation

scenario_dir="${project_root}/scenarios/${scenario_name}"
cd ${scenario_dir} || exit 1

poetry run bash ./test/main.sh "${project_root}"
