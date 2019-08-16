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

cd "${project_root}" || exit 2
target_dir="${project_root}/scenarios/${target_name}"
mkdir -p "${target_dir}"

function init_if_missing() {
    f_path="${target_dir}/$1"
    data="$2"
    if [[ ! -e ${f_path} || "${FORCE}" == "1" ]]; then
        echo "${data}" > "${f_path}"
        echo "File ${f_path} initialized."
    else
        echo "File ${f_path} already exists."
    fi

}

# initialize terraform + some scripts
shebang="#!/usr/bin/env bash"
init_if_missing "pre_build.sh" "${shebang}"
init_if_missing "post_build.sh" "${shebang}"
init_if_missing "terraform.tfvars" \
"region = \"eu-de\"
tenant_name = \"eu-de_rus\"
default_az = \"eu-de-01\"
domain_name = \"OTC00000000001000000447\""
init_if_missing "secrets.auto.tfvars" \
"username = \"\"
password = \"\""
# let's pretend that target_dir is playbooks dir and create empty ansible playbook
target_dir="${project_root}/playbooks" init_if_missing "${target_name}_setup.yml" "---"

tf_template="terraform {
  required_providers {
    opentelekomcloud = \">= 1.11.0\"
  }
}

variable \"username\" {}
variable \"password\" {}
variable \"region\" {}
variable \"tenant_name\" {}
variable \"default_az\" {}
variable \"domain_name\" {}

# Configure the OpenTelekomCloud Provider
provider \"opentelekomcloud\" {
  user_name = var.username
  password = var.password
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url = \"https://iam.eu-de.otc.t-systems.com:443/v3\"
}"
init_if_missing "infrastructure.tf" "${tf_template}"
cd "${target_dir}" || exit 2
terraform init
