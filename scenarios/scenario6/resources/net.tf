#VPC creation
resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "${var.prefix}-vpc"
  cidr = "${var.net_address}.0/16"
}

#Subnet creation
resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name        = "${var.prefix}-subnet"
  cidr        = "${var.net_address}.0/24"
  gateway_ip  = "${var.net_address}.1"
  vpc_id      = opentelekomcloud_vpc_v1.vpc.id
  primary_dns = "8.8.8.8"

  depends_on = [
    opentelekomcloud_vpc_v1.vpc
  ]
}

#Output value for subnet
output "subnet" {
  value = opentelekomcloud_vpc_subnet_v1.subnet
}

#Output value for vpc id
output "vpc_id" {
  value = opentelekomcloud_vpc_v1.vpc.id
}

