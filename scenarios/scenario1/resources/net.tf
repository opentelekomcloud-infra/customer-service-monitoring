# Network creation
resource "opentelekomcloud_networking_network_v2" "generic" {
  name                = "network-generic"
}

# Router creation
resource "opentelekomcloud_networking_router_v2" "generic" {
  name                = "router"
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