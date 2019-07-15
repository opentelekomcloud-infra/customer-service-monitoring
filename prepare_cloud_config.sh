#!/bin/bash

echo "clouds.yml and secure.yml should exist in current directory."

dir="/etc/openstack"
if [ ! -d  "$dir" ]; then
    echo "Directory "$dir" not exists."
    mkdir -p /etc/openstack
    cp clouds.yml secure.yml "$dir"
else
    cp clouds.yml secure.yml "$dir"
fi