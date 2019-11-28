#!/usr/bin/env bash

scenario_name="$1"
shift  # get rid of first argument

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

echo "Environment variables: "
env

export PROJECT_ROOT=$(bash ./core/get_project_root.sh)

# first - build infra
terraform_dir="${PROJECT_ROOT}/scenarios/${scenario_name}"
pre_build="../core/pre_build.sh"
post_build="./post_build.sh"


cd "${terraform_dir}" || exit 1
terraform init
source "${pre_build}" ${scenario_name}
terraform apply -auto-approve -input=false "$@" || exit  # pass all scripts arguments to terraform build (for -var support)

# create inventory file after build infrastructure
file="${terraform_dir}/scenario_state"
terraform state pull > ${file} || exit $?

python3 "${PROJECT_ROOT}/scenarios/core/create_inventory.py" ${file} --name ${scenario_name}

cd "${terraform_dir}" || exit 1
if [[ -e ${post_build} ]]; then source "${post_build}"; fi # here goes setting up env variables
# second - configure build infra
cd "${PROJECT_ROOT}" || exit 1
ansible-playbook -i "inventory/prod" "playbooks/${scenario_name}_setup.yml"
