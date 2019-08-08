#!/usr/bin/env bash
# Build skeleton for new scenario

if [[ -z $1 ]]; then
    echo "Scenario ID is missing"
fi

target_name="$1"
project_root=$( sh ./get_project_root.sh )

cd ${project_root}
scn_folder="${project_root}/scenarios/${target_name}"
mkdir -p ${scn_folder}

shebang="#!/usr/bin/env bash"
pre_b="${scn_folder}/pre_build.sh"
if [[ ! -e ${pre_b} ]]; then echo "${shebang}" > "${pre_b}"; fi
post_b="${scn_folder}/post_build.sh"
if [[ ! -e "${post_b}" ]]; then echo "${shebang}" > "${post_b}"; fi

tf_template="terraform {
  required_providers {
    opentelekomcloud = \">= 1.11.0\"
  }
}

variable \"username\" {}
variable \"password\" {}

# Configure the OpenTelekomCloud Provider
provider \"opentelekomcloud\" {
  user_name = var.username
  password = var.password
  domain_name = \"OTC00000000001000000447\"
  tenant_name = \"eu-de_rus\"
  auth_url = \"https://iam.eu-de.otc.t-systems.com:443/v3\"
}
"
infra_tf="${scn_folder}/infrastructure.tf"
if [[ ! -e "${infra_tf}" ]]; then echo "${shebang}" > "${post_b}"; fi
echo "${tf_template}" > "${infra_tf}"

touch "${project_root}/playbooks/scenarios/${target_name}_setup.yml"
