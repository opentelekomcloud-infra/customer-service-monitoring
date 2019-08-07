terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }
}

variable "password" {}
variable "username" {}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = "OTC00000000001000000447"
  tenant_name = "eu-de_rus"
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}


resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "net_scn2"
  cidr = "192.168.0.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name = "subnet_scn2"
  cidr = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id = opentelekomcloud_vpc_v1.vpc.id
  depends_on = [
    opentelekomcloud_vpc_v1.vpc
  ]
}

resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name = "csn2_pair"
}

resource "opentelekomcloud_compute_instance_v2" "basic" {
  name = "scn2_server"
  image_name = "Standard_CentOS_7_latest"
  flavor_id = "s2.medium.1"
  security_groups = [
    "default"
  ]
  region = "eu-de_rus"
  availability_zone = "eu-de-01"
  key_pair = opentelekomcloud_compute_keypair_v2.pair.name

  depends_on = [
    opentelekomcloud_vpc_subnet_v1.subnet,
    opentelekomcloud_compute_keypair_v2.pair,
  ]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }

}
