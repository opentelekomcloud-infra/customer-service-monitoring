#!/usr/bin/env bash

ssh-keygen -f ~/.ssh/known_hosts -R csm.outcatcher.com
file_name="scn1_instance_rsa"
export RSA_PRIVATE_KEY="$( pwd )/${file_name}"
ssh-add -d "${RSA_PRIVATE_KEY}"
yes y | ssh-keygen -qf "${RSA_PRIVATE_KEY}" -t rsa -N ''
ssh-add "${RSA_PRIVATE_KEY}"
echo "${RSA_PRIVATE_KEY}.pub"
export TF_VAR_public_key=$( < "${RSA_PRIVATE_KEY}.pub" )
echo "ECS public key: ${TF_VAR_public_key}"
