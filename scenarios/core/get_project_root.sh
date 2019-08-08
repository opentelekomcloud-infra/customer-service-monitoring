#!/usr/bin/env bash
MY_PATH="$(cd "$(dirname "$0")/../.." && pwd)"
if [[ -z "$MY_PATH" ]]; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1 # fail
fi
echo "$MY_PATH"
