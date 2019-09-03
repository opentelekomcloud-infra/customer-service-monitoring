#!/usr/bin/env bash
output="$( terraform show | grep "out-" )"

function get_value() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}

export PSQL_PASSWORD=$( get_value "db_password" )
export PSQL_USERNAME=$( get_value "db_username" )
export PSQL_ADDRESS=$( get_value "db_address" )
export SERVER_PUBLIC_IP=$( get_value "scn2_public_ip" )
