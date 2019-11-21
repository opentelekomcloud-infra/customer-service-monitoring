# Network creation
resource "opentelekomcloud_networking_network_v2" "network" {
  name = "${var.prefix}_network"
}

data "opentelekomcloud_networking_network_v2" "extnet" {
  name = "admin_external_net"
}

# Router creation
resource "opentelekomcloud_networking_router_v2" "router" {
  name             = "${var.prefix}_router"
  external_gateway = data.opentelekomcloud_networking_network_v2.extnet.id
  enable_snat      = true
}

# Subnet http configuration
resource "opentelekomcloud_networking_subnet_v2" "subnet" {
  name            = "${var.prefix}_subnet"
  network_id      = opentelekomcloud_networking_network_v2.network.id
  cidr            = "${var.addr_3_octets}.0/16"
  dns_nameservers = ["100.125.4.25", "100.125.129.199"]
}


# Router interface configuration
resource "opentelekomcloud_networking_router_interface_v2" "http" {
  router_id = opentelekomcloud_networking_router_v2.router.id
  subnet_id = opentelekomcloud_networking_subnet_v2.subnet.id
}

output "subnet" {
  value = opentelekomcloud_networking_subnet_v2.subnet
}

output "network" {
  value = opentelekomcloud_networking_network_v2.network
}

output "router" {
  value = opentelekomcloud_networking_router_v2.router
}
