#!/usr/bin/env bash

file_name="scn2_instance_rsa"
export RSA_PRIVATE_KEY="$( pwd )/${file_name}"
ssh-add -d "${RSA_PRIVATE_KEY}"

python3 "${parent_dir}/core/get_key.py" -k "key/${file_name}" -o ${RSA_PRIVATE_KEY}
sudo chmod 600 ${file_name}

ssh-add "${RSA_PRIVATE_KEY}" || exit 3
ssh-keygen -y -f  ${RSA_PRIVATE_KEY} > "${RSA_PRIVATE_KEY}.pub"
echo "${RSA_PRIVATE_KEY}.pub"
export TF_VAR_public_key=$( < "${RSA_PRIVATE_KEY}.pub" )
echo "ECS public key: ${TF_VAR_public_key}"
