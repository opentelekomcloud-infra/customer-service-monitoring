region            = "eu-de"
tenant_name       = "eu-de_rus"
availability_zone = "eu-de-01"
domain_name       = "OTC00000000001000000447"

postfix = "scn1_5"

ecs_flavor  = "s2.large.2"
ecs_image   = "Standard_Debian_9_latest"
nodes_count = 2

bastion_eip      = "80.158.3.174"
loadbalancer_eip = "80.158.23.240"
