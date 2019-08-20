#!/usr/bin/env bash
output="$( terraform show | grep "out-" )"

function substr() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}

export PSQL_PASSWORD=$( substr "db_password" )
export PSQL_USERNAME=$( substr "db_username" )
export PSQL_ADDRESS=$( substr "db_address" )
export SERVER_PUBLIC_IP=$( substr "scn2_public_ip" )
