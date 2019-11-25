#!/usr/bin/env bash
output="$( terraform show | grep "out-" )"

function get_value() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}

export TARGET_SERVER_PUBLIC_IP=$( get_value "scn3_5_target_fip" )
export INITIATOR_SERVER_PUBLIC_IP=$( get_value "scn3_5_initiator_fip" )
export ISCSI_DEVICE_NAME=$( get_value "scn3_5_iscsi_device_name" )