#!/usr/bin/env bash
output="$(terraform show | grep "out-")"

function get_value() {
    var_name=$1
    echo $(echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//')
}

export LOADBALANCER_PUBLIC_IP=$(get_value "scn4_lb_fip")
export BASTION_PUBLIC_IP=$(get_value "scn4_bastion_fip")
