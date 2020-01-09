#!/usr/bin/env bash

scenario_name="$1"

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

project_root=$(bash ./core/get_project_root.sh)

terraform_dir="${project_root}/scenarios/${scenario_name}"

cd ${terraform_dir} || exit 1
terraform init
terraform destroy --auto-approve
