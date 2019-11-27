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

# init pre-/post-build scripts
init_if_missing "pre_build.sh" "${shebang}"
init_if_missing "post_build.sh" "$(<"./core/post_build_template.sh")"

# init tests
mkdir -p "${target_dir}/test"

init_if_missing "test/main.sh" "${shebang}
start_dir=\$( pwd )
local_dir=\$( cd \$( dirname \"\$0\" ); pwd )
project_root=\$1
echo \"Project root: \${project_root}\"


scenario_dir=\$(cd \"\${local_dir}/..\"; pwd)
echo \"Scenario directory: \${scenario_dir}\"
cd \"\${scenario_dir}\" || exit 1
# source ./pre_build.sh

cd \"\${project_root}\" || exit 1

function run_test() {
    python \"\${local_dir}/main.py\"  # <arguments>
}

cd \${start_dir}"
init_if_missing "test/main.py" ""

# init terraform configuration
init_if_missing "terraform.tfvars" \
"region = \"eu-de\"
tenant_name = \"eu-de_rus\"
availability_zone = \"eu-de-01\"
domain_name = \"OTC00000000001000000447\""
init_if_missing "secrets.auto.tfvars" \
"username = \"\"
password = \"\""
# create empty ansible playbook
target_dir="${project_root}/playbooks" init_if_missing "${target_name}_setup.yml" "---"

init_if_missing "settings.tf" "terraform {
  required_providers {
    opentelekomcloud = \">= 1.11.0\"
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
  user_name = var.username
  password = var.password
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url = \"https://iam.eu-de.otc.t-systems.com:443/v3\"
}"

init_if_missing "variables.tf" "variable \"username\" {}
variable \"password\" {}
variable \"region\" {}
variable \"tenant_name\" {}
variable \"availability_zone\" {}
variable \"domain_name\" {}"

cd "${target_dir}" || exit 2
terraform init
