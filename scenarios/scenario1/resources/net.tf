#### NETWORK CONFIGURATION ####

# VPC creation
resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "net_${var.postfix}"
  cidr = "${var.net_address}.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name = ""
  cidr = "${var.net_address}.0/24"
  gateway_ip = "${var.net_address}.1"
  vpc_id = opentelekomcloud_vpc_v1.vpc.id
  primary_dns = "8.8.8.8"
  depends_on = [ "opentelekomcloud_vpc_v1.vpc" ]
}
