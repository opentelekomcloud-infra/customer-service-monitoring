# Sandbox
POC of the platform KPI monitoring

## Install galaxy roles

Multiple playbooks are using galaxy roles, so it is required to install those.

```
    ansible-galaxy install -r requirements.yml
```

### Prerequisites
	
 - ansible - should be at least 2.8.1
 - python3-openstacksdk - should be at least 0.26.x
 - prepare cloud.yml and secure.yml and put it in project root directory
 - ./prepare_cloud_config.sh
 - on runner: export OS_CLOUD="cloud_name_from_clouds.yml"

### Inventory

Inventory must be prepared, already before the infrastructure can be provisioned. This is required to know how to name resources, which FQDNs to use, which private keys to use to access instances.

Inventory consists of following components:

- group_vars/all.yaml - contains common variables, ssl keys, domain name, etc


### Infrastructure provisioning

Ansible can be used to provision infrastructure on top of the OpenStack, For that a proper cloud connection should be present on the management host (presumably localhost) - clouds.yaml

Returns token for provided in all.yml cloud:
```
    ansible-playbook -i inventory/prod playbooks/scenarios/get_token.yml
```
Return openstack client config uses data from clouds.yml:
```
    ansible-playbook -i inventory/prod playbooks/scenarios/test_config.yml
```
Simple connection test, returns list of images and servers:
```
    ansible-playbook -i inventory/prod playbooks/scenarios/test_connection.yml
```
Simple ecs creation script:
 - Create Keypair
 - Create VPC
 - Create Security Group and add security role
 - Create Server 
 - Get Server Meta Data 
 - Modify Server Metadata 
 - Delete metadata 
 - Set Tags on the Server 
 - Delete Server with all required resources 
 - Delete SecurityGroupRule 
 - Delete SecurityGroup 
 - Delete VPC 
 - Delete Keypair
```
    ansible-playbook -i inventory/prod playbooks/scenarios/ecs_creation.yml
```
