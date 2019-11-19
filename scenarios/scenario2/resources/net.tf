resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "net_${var.postfix}"
  cidr = "${var.net_address}.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name        = "subnet_${var.postfix}"
  cidr        = "${var.net_address}.0/24"
  gateway_ip  = "${var.net_address}.1"
  vpc_id      = opentelekomcloud_vpc_v1.vpc.id
  dns_list    = ["1.1.1.1", "8.8.8.8", "100.125.4.25", "100.125.129.199"]

  depends_on = [
    opentelekomcloud_vpc_v1.vpc
  ]
}

output "subnet" {
  value = opentelekomcloud_vpc_subnet_v1.subnet
}

output "vpc_id" {
  value = opentelekomcloud_vpc_v1.vpc.id
}
