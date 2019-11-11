# Customer Service Monitoring
T-Systems solution for customer KPI monitoring for Open Telekom Cloud

[![Build Status](https://travis-ci.org/opentelekomcloud-infra/customer-service-monitoring.svg?branch=master)](https://travis-ci.org/opentelekomcloud-infra/customer-service-monitoring)

This repository contains customer service monitoring test scenarios for 
**Open Telekom Cloud**

## Infrastructure
Infrastructure for test scenarios is built using Terraform and Ansible.

### Requirements
Existing scripts were checked to be working with:
 - Terraform 0.12
 - Ansible 2.7 (Python 3.7)

Installing of terraform for linux can be done using `install_terraform.sh`

### Build

Existing scenario infrastructure build can be triggered using `scenarios/build.sh`

**!NB** Terraform is using OBS for storing remote state
Following variables have to be set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

E.g. for scenario 2 following should be used:
```bash
cd scenarios
export AWS_ACCESS_KEY_ID=myau_id
export AWS_SECRET_ACCESS_KEY=sekret_myau
./build.sh scenario2
```
This script perform the following actions:
 1. Build required infrastructure using configuration from `scenarios/scenario2/` directory
 1. Run `scenario2_setup.yml` playbook from `playbooks/` for created host

There is no credentials stored in `terraform.tfvars` file for the scenario. Recommended way to
define credentials and overriding is to create some `*.auto.tfvars` file in scenario directory,
e.g. `secrets.auto.tfvars`. See [variables documentation](https://www.terraform.io/docs/configuration/variables.html)
for details.

### Execution

There is `test.sh` script for running tests/monitoring defined in `scenario/test/main.sh` \
Implementation of most tests can be found in [csm test utils](https://github.com/opentelekomcloud-infra/csm-test-utils) repository
