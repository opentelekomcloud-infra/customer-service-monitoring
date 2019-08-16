#!/usr/bin/env bash
output="$( terraform show | grep "out-" )"

function substr() {
    var_name=$1
    echo $( echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//' )
}
