#### NETWORK CONFIGURATION ####

# VPC creation
/*resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "net_${var.postfix}"
  cidr = "${var.net_address}.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name = "subnet_${var.postfix}"
  cidr = "${var.net_address}.0/24"
  gateway_ip = "${var.net_address}.1"
  vpc_id = opentelekomcloud_vpc_v1.vpc.id
  primary_dns = "8.8.8.8"
  depends_on = [ "opentelekomcloud_vpc_v1.vpc" ]
}

resource "opentelekomcloud_networking_network_v2" "network" {
  name           = "scn1_network"
  admin_state_up = "true"
}

resource "opentelekomcloud_networking_subnet_v2" "subnet" {
  name       = "scn1_subnet"
  network_id = "${opentelekomcloud_networking_network_v2.network.id}"
  cidr       = "${var.net_address}.0/24"
} */

#### NETWORK CONFIGURATION ####

# Router creation
resource "opentelekomcloud_networking_router_v2" "generic" {
  name                = "router"
  external_network_id = "f67f0d72-0ddf-11e4-9d95-e1f29f417e2f"
}

# Network creation
resource "opentelekomcloud_networking_network_v2" "generic" {
  name                = "network-generic"
}

#### HTTP SUBNET ####

# Subnet http configuration
resource "opentelekomcloud_networking_subnet_v2" "subnet" {
  name                = "${var.postfix}_subnet"
  network_id          = "${opentelekomcloud_networking_network_v2.generic.id}"
  cidr                = "${var.net_address}.0/16"
  dns_nameservers     =  ["8.8.8.8", "8.8.8.4"]
}

# Router interface configuration
resource "opentelekomcloud_networking_router_interface_v2" "http" {
  router_id           = "${opentelekomcloud_networking_router_v2.generic.id}"
  subnet_id           = "${opentelekomcloud_networking_subnet_v2.subnet.id}"
}