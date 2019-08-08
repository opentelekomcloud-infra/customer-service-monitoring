#!/usr/bin/env bash

scenario_name="scenario$1"

project_root=$( sh ./get_project_root.sh )
pre_build="pre_build.sh"
post_build="post_build.sh"


# first — build infra
terraform_dir="${project_root}/scenarios/${scenario_name}"
cd ${terraform_dir}
if [[ -z ${pre_build} ]]; then bash ${pre_build}; fi
terraform apply -auto-approve -input=false
if [[ -z ${post_build} ]]; then bash ${post_build}; fi  # here goes setting up env variables

# second — configure build infra
cd ${project_root}
ansible-playbook -i "inventory/prod" "playbooks/${scenario_name}_setup.yml"
