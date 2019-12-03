#!/usr/bin/env bash

scenario_name="$1"
shift # get rid of first argument

if [[ -z ${scenario_name} ]]; then
    echo "Scenario name is missing"
    exit 2
fi

secrets="$(pwd)/secrets/secrets.packer.cloud.sh"
packer_json="$(pwd)/${scenario_name}/packer_image.json"

echo "Create images for scenario"
source "${secrets}"
packer validate "${packer_json}"
packer build "${packer_json}"
