#!/usr/bin/env bash
version=1.4.4
wget https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip
sudo unzip packer_${version}_linux_amd64.zip -d /usr/local/bin
