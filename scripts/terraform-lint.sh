#!/usr/bin/bash
scenarios_path="$(pwd)/scenarios"

terraform fmt -check -recursive "$scenarios_path" || exit 1

function check() {
  cd "$1" || return 2
  echo "Checking $1"
  terraform init --backend=false --input=false > /dev/null || return 2
  echo "Successfully Initialized"
  terraform validate || return 2
}

# run tf validate for each scenario
scenarios=$(find "$scenarios_path" -maxdepth 1)

status=0
for scn in ${scenarios}
do
  check "${scn}" || status=2
done

exit $status
