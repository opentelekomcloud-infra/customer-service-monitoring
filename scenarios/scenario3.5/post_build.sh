#!/usr/bin/env bash
output="$( terraform show | grep "out-" )"

function get_value() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}

export SERVER_PUBLIC_IP=$( get_value "scn3.5_server_fip" )