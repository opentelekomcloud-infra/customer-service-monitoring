#!/usr/bin/env bash

parent_dir="$(cd "$(dirname "$0")/.." && pwd)"

rm -f  ~/.ssh/known_hosts
file_name="scn1_instance_rsa"
export RSA_PRIVATE_KEY="$( pwd )/${file_name}"
ssh-add -d "${RSA_PRIVATE_KEY}"

python3 "${parent_dir}/core/get_key.py" --key "key/${file_name}" -o "scn1_instance_rsa"
sudo chmod 600 ${file_name}

ssh-add "${RSA_PRIVATE_KEY}"
echo "${RSA_PRIVATE_KEY}.pub"
export TF_VAR_public_key=$( < "${RSA_PRIVATE_KEY}.pub" )
echo "ECS public key: ${TF_VAR_public_key}"
