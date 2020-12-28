#!/usr/bin/bash
echo "TF version: $1"
echo "Output path: $2"

local_zip="$2/terraform_$1_linux_amd64.zip"
local_exec="$2/terraform"

if [[ -f "$local_exec" ]]; then
  exit 0
fi

if [[ ! -f "$local_zip" ]]; then
  curl "https://releases.hashicorp.com/terraform/$1/terraform_$1_linux_amd64.zip" -o "$local_zip"
fi

unzip "$local_zip" -d "$2"
