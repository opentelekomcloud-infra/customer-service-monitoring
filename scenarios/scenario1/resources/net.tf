# Network creation
resource "opentelekomcloud_networking_network_v2" "generic" {
  name                = "network-generic"
}

data  "opentelekomcloud_networking_network_v2" "extnet" {
  name                = "admin_external_net"
}

# Router creation
resource "opentelekomcloud_networking_router_v2" "generic" {
  name                = "router"
  external_gateway = data.opentelekomcloud_networking_network_v2.extnet.id
  enable_snat         = true
}

# Subnet http configuration
resource "opentelekomcloud_networking_subnet_v2" "subnet" {
  name                = "${var.postfix}_subnet"
  network_id          = opentelekomcloud_networking_network_v2.generic.id
  cidr                = "${var.net_address}.0/16"
  dns_nameservers     =  ["8.8.8.8", "8.8.8.4"]
}

# Router interface configuration
resource "opentelekomcloud_networking_router_interface_v2" "http" {
  router_id           = opentelekomcloud_networking_router_v2.generic.id
  subnet_id           = opentelekomcloud_networking_subnet_v2.subnet.id
}

resource "opentelekomcloud_networking_router_route_v2" "router_route_1" {
  depends_on       = ["opentelekomcloud_networking_router_interface_v2.http"]
  router_id        = opentelekomcloud_networking_router_v2.generic.id
  destination_cidr = "0.0.0.0/0"
  next_hop         = var.bastion_local_ip
}