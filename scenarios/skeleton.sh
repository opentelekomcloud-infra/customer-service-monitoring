#!/usr/bin/env bash
# Build skeleton for new scenario

if [[ -z $1 ]]; then
  echo "Scenario ID is missing"
  exit 1
fi

FORCE=0
if [[ "$2" == "--force" ]]; then
  FORCE=1
  echo "All existing files will be overwritten"
fi

target_name="$1"
project_root=$(sh ./core/get_project_root.sh)

target_dir="${project_root}/scenarios/${target_name}"
mkdir -p "${target_dir}"

# initialize terraform + some scripts
shebang="#!/usr/bin/env bash"
function init_if_missing() {
  f_path="${target_dir}/$1"
  data="$2"
  if [[ ! -e ${f_path} || "${FORCE}" == "1" ]]; then
    echo "${data}" >"${f_path}"
    echo "File ${f_path} initialized."
  else
    echo "File ${f_path} already exists."
  fi
}

# init terraform configuration
init_if_missing "terraform.tfvars" \
"region = \"eu-de\"
availability_zone = \"eu-de-01\""
# create empty ansible playbook
target_dir="${project_root}/playbooks" init_if_missing "${target_name}_setup.yml" "---"

init_if_missing "settings.tf" "terraform {
  required_providers {
    opentelekomcloud = \">= 1.16.0\"
  }

  backend \"s3\" {  # use OBS for remote state
    key = \"terraform_state/${target_name}\"
    endpoint =  \"obs.eu-de.otc.t-systems.com\"
    bucket = \"obs-csm\"
    region = \"eu-de\"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}

# Configure the OpenTelekomCloud Provider
provider \"opentelekomcloud\" {
    cloud = \"devstack\"
}"

init_if_missing "variables.tf" "---"

