#!/usr/bin/bash
apt update -y || exit 2
apt install -y curl unzip || exit 2
curl https://releases.hashicorp.com/terraform/0.14.2/terraform_0.14.2_linux_amd64.zip -o terraform_0.14.2_linux_amd64.zip || exit 2
unzip terraform_0.14.2_linux_amd64.zip -d /usr/local/bin || exit 2
