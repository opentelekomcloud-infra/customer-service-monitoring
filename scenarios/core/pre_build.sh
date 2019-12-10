#!/usr/bin/env bash

parent_dir="$(cd "$(dirname "$0")/.." && pwd)"
number=$(echo $1 | grep -o -E "[0-9_]+$")

rm -f ~/.ssh/known_hosts
file_name="scn${number}_instance_rsa"
export RSA_PRIVATE_KEY="$(pwd)/${file_name}"
ssh-add -d "${RSA_PRIVATE_KEY}"

python3 "${parent_dir}/core/get_key.py" -k "key/${file_name}" -o ${RSA_PRIVATE_KEY} <<< ${RSA_PASSWORD}

echo ${RSA_PASSWORD} > ssh-add "${RSA_PRIVATE_KEY}"|| exit 3
ssh-keygen -y -f ${RSA_PRIVATE_KEY} > "${RSA_PRIVATE_KEY}.pub"
echo "${RSA_PRIVATE_KEY}.pub"
export TF_VAR_public_key=$(<"${RSA_PRIVATE_KEY}.pub")
echo "ECS public key: ${TF_VAR_public_key}"
