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

Installing terraform for Linux can be done using `install_terraform.sh`

### Build

Existing scenario infrastructure build can be triggered using `ansible-playbook playbooks/scenario*_setup.yml`

**!NB** Terraform is using OBS for storing remote state
Following variables have to be set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

E.g. for scenario 2 following should be used:
```bash
cd scenarios
export AWS_ACCESS_KEY_ID=myau_id
export AWS_SECRET_ACCESS_KEY=sekret_myau
ansible-playbook "playbooks/scneario2_setup.yml"
```
This script performs the following actions:
 1. Build required infrastructure using the configuration from `scenarios/scenario2/` directory
 1. Run `scenario2_setup.yml` playbook from `playbooks/` for created host

There are no credentials stored in `terraform.tfvars` file for the scenario. It is used file called "clouds.yaml" for authentication.
It must contain credentials and locate in one of the next places:
 1. `current directory`
 2. `~/.config/openstack`
 3. `/etc/openstack`
In case of you have more than one cloud you should set environment variable `OS_CLOUD`
See [openstack configuration](https://docs.openstack.org/python-openstackclient/pike/configuration/index.html) for details.

### Execution

Executed playbook also starts test/monitoring for created/refreshed infrastructure. \
Implementation of most tests can be found in [csm test utils](https://github.com/opentelekomcloud-infra/csm-test-utils) repository
