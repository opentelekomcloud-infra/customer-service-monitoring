#!/usr/bin/env bash

scenario_name="$1"
shift  # get rid of first argument

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
terraform init
if [[ -e ${pre_build} ]]; then source "${pre_build}"; fi
terraform apply -auto-approve -input=false "$@" || exit  # pass all scripts arguments to terraform build (for -var support)

# create inventory file after build infrastructure
file="${terraform_dir}/scenario_state"
terraform state pull > ${file} || exit $?

python3 "${project_root}/scenarios/core/create_inventory.py" ${file} --name ${scenario_name}

cd "${terraform_dir}" || exit 1
if [[ -e ${post_build} ]]; then source "${post_build}"; fi # here goes setting up env variables
# second - configure build infra
cd "${project_root}" || exit 1
ansible-playbook -i "inventory/prod" "playbooks/${scenario_name}_setup.yml"
