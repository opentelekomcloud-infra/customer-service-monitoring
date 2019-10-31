#!/usr/bin/env bash

# Searching for variables starting from "out-..." in current state
output="$( terraform show | grep "out-" )"

# Find variable value in Terraform output
function get_value() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}

scn_dir=$(pwd)

export OTC_SEC_GROUP=$( get_value "group" )
export OTC_IMAGE_ID=$( get_value "image_id" )
export OTC_NETWORK_ID=$( get_value "network_id" )

if [[ -z ${PROJECT_ROOT} ]]; then
    echo "PROJECT_ROOT is not defined"
    echo "post_build.sh should be started with ./build.sh"
    exit 1
fi
cd ${PROJECT_ROOT} || exit 1

cd ./images

for dir in $(find -name "packer_image.json" -printf '%h\n' | sort -u)
do
    bash build_image.sh ${dir}
done

cd ${scn_dir}
terraform destroy -auto-approve
cd ..

exit 0  # post_build is sourced by build, so build will finish here
