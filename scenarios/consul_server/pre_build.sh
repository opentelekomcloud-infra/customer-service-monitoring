#!/usr/bin/env bash

export TF_VAR_public_ip="80.158.23.135"
export TF_VAR_public_key="$(< consul.pub)"

root_path="$( sh ./../get_project_root.sh )"

"${root_path}/inventory" < echo "${TF_VAR_public_ip}"
