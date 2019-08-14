resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "net_${var.postfix}"
  cidr = "${var.net_address}.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name = "subnet_${var.postfix}"
  cidr = "${var.net_address}.0/24"
  gateway_ip = "${var.net_address}.1"
  vpc_id = opentelekomcloud_vpc_v1.vpc.id
  depends_on = [
    opentelekomcloud_vpc_v1.vpc
  ]
}

resource "opentelekomcloud_compute_secgroup_v2" "local_only" {
  description = "Sec group with only local access"
  name = var.local_only_sg
}
