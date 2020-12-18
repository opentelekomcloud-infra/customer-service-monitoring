#!/usr/bin/bash
terraform fmt -check -recursive ./scenarios/ || exit 1

# run tf validate for each scenario
scenarios=$(find ./scenarios -maxdepth 1)
status=0
function check() {
  echo "Checking $1"
  terraform init --backend=false --input=false "$1" > /dev/null || return 2
  echo "Initialized $1"
  terraform validate "$1" || return 2
}

for scn in ${scenarios}
do
  check "${scn}" || status=2
done

exit $status
