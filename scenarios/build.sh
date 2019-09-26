#!/usr/bin/env bash

scenario_name="$1"

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

project_root=$(bash ./core/get_project_root.sh)

# first - build infra
terraform_dir="${project_root}/scenarios/${scenario_name}"
pre_build="./pre_build.sh"
post_build="./post_build.sh"


cd "${terraform_dir}" || exit 1
if [[ -e ${pre_build} ]]; then source "${pre_build}"; fi
terraform apply -auto-approve -input=false || exit

# create inventory file after build infrastructure
cd "${project_root}/scenarios" || exit 1
python3 ./core/create_inventory.py -s ${scenario_name}

cd "${terraform_dir}" || exit 1
if [[ -e ${post_build} ]]; then source "${post_build}"; fi # here goes setting up env variables
# second - configure build infra
cd "${project_root}" || exit 1
ansible-playbook -i "inventory/prod" "playbooks/${scenario_name}_setup.yml"
