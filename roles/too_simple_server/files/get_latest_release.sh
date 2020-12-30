#!/usr/bin/env bash

curl --silent "https://api.github.com/repos/opentelekomcloud-infra/simple-exquisite-webserver/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                                                                           # Get tag line
  sed -E 's/.*"v(.+?)".*/\1/'                                                                                   # Pluck JSON value
