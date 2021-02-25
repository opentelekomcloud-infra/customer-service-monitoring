# Customer Service Monitoring
T-Systems solution for customer KPI monitoring for Open Telekom Cloud

[![Zuul Check](https://zuul.eco.tsi-dev.otc-service.com/api/tenant/eco/badge?project=opentelekomcloud-infra/customer-service-monitoring&pipeline=check&branch=devel)](https://zuul.eco.tsi-dev.otc-service.com/t/eco/builds?project=opentelekomcloud-infra/customer-service-monitoring)

This repository contains customer service monitoring test scenarios for 
**Open Telekom Cloud**

## Infrastructure
Infrastructure for test scenarios is built using Ansible. It uses openstack.cloud and opentelekomcloud.cloud ansible modules.

### Requirements
Existing scripts were checked to be working with:
 - Ansible 2.9 (Python 3.7)

### Build

Existing scenario infrastructure build can be triggered using `ansible-playbook playbooks/*_monitoring_setup.yml`

**!NB** To provide access to OBS, following variables have to be set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

E.g. for scenario 2 following should be used:
```bash
export AWS_ACCESS_KEY_ID=myau_id
export AWS_SECRET_ACCESS_KEY=sekret_myau
export OS_CLOUD=mycloud
ansible-playbook "playbooks/dns_monitoring_setup.yml"
```
This script performs the following actions:
 1. Build required infrastructure using different roles from roles/
 2. Configure created infrastructure using respective playbook from playbooks/ for infrastructure monitoring

Credentials should be stored in the file called "clouds.yaml".
It must locate in one of the next places:
 1. `current directory`
 2. `~/.config/openstack`
 3. `/etc/openstack`
In case of you have more than one cloud you should set environment variable `OS_CLOUD`
See [openstack configuration](https://docs.openstack.org/python-openstackclient/pike/configuration/index.html) for details.

### Execution

Executed playbook also starts test/monitoring for created/refreshed infrastructure. \
Implementation of most tests can be found in [csm test utils](https://github.com/opentelekomcloud-infra/csm-test-utils) repository
