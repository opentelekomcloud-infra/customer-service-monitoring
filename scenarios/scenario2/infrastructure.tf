terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }
}

variable "username" {}
variable "password" {}
variable "postfix" {}
variable "net_address" {}
variable "region" {}
variable "public_key" {
  default = null
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = "OTC00000000001000000447"
  tenant_name = "eu-de_rus"
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}


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

resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name = "csn2_${var.postfix}"
  public_key = var.public_key
}

resource "opentelekomcloud_networking_floatingip_v2" "public_ip" {}


resource "opentelekomcloud_compute_instance_v2" "basic" {
  name = "${var.postfix}_server"
  image_name = "Standard_CentOS_7_latest"
  flavor_id = "s2.medium.1"
  security_groups = [
    "default"
  ]
  region = var.region
  availability_zone = "${var.region}-01"
  key_pair = opentelekomcloud_compute_keypair_v2.pair.name

  depends_on = [
    opentelekomcloud_vpc_subnet_v1.subnet,
    opentelekomcloud_compute_keypair_v2.pair,
  ]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }

}

resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.public_ip.address
  instance_id = opentelekomcloud_compute_instance_v2.basic.id
}
