#!/usr/bin/env bash
# Build skeleton for new scenario

if [[ -z $1 ]]; then
  echo "Scenario ID is missing"
  exit 1
fi

target_name="$1"
project_root=$(sh ./core/get_project_root.sh)

cd "${project_root}" || exit 2
scn_folder="${project_root}/scenarios/${target_name}"
mkdir -p "${scn_folder}"

shebang="#!/usr/bin/env bash\n"

function init_if_missing() {
    f_path="${scn_folder}/$1"
    data="$2"
    if [[ ! -e ${f_path} ]]; then
        echo "${data}" > "${f_path}"
    fi
    echo "File ${f_path} initialized"
}

init_if_missing "pre_build.sh" "${shebang}"
init_if_missing "post_build.sh" "${shebang}"

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
init_if_missing "infrastructure.tf" "${tf_template}"
terraform init "${scn_folder}"

touch "${project_root}/playbooks/scenarios/${target_name}_setup.yml"
