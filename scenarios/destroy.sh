#!/usr/bin/env bash

scenario_name="$1"

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

project_root=$(bash ./core/get_project_root.sh)

# first - build infra
terraform_dir="${project_root}/scenarios/${scenario_name}"

cd ${terraform_dir} || exit 1
terraform destroy --auto-approve