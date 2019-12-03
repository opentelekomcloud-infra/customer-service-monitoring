#!/usr/bin/env bash

# Searching for variables starting from "out-..." in current state
output="$(terraform show | grep "out-")"

# Find variable value in Terraform output
function get_value() {
    var_name=$1
    echo $(echo "${output}" | grep -E "${var_name} =" | grep -oE "\"(.+)\"" | sed -e 's/^"//' -e 's/"$//')
}
