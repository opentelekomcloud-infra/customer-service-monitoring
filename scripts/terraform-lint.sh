#!/usr/bin/bash
terraform fmt -check -recursive ./scenarios/ || exit 1
find ./scenarios/* -name "scenario*" -exec sh -c 'terraform init "$1" && terraform validate "$1"' _ {} \;
