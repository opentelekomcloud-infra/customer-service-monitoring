terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }
}

variable "username" {}
variable "password" {}
variable "public_key" {}
variable "public_ip" {}
variable "region" {}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = "OTC00000000001000000447"
  tenant_name = "eu-de_rus"
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}

resource "opentelekomcloud_vpc_v1" "consul_vpc" {
  cidr = "192.168.0.0/16"
  name = "consul_net"
}

resource "opentelekomcloud_vpc_subnet_v1" "consul_subnet" {
  cidr = "192.168.0.0/24"
  vpc_id = opentelekomcloud_vpc_v1.consul_vpc.id
  gateway_ip = "192.168.0.1"
  name = "consul_subnet"
}

resource "opentelekomcloud_compute_keypair_v2" "consul_pub" {
  name = "consul_pub"
  public_key = var.public_key
}

resource "opentelekomcloud_compute_instance_v2" "consul_host" {
  name = "consul_server"
  image_name = "Standard_CentOS_7_latest"
  flavor_id = "s2.medium.1"
  security_groups = [
    "default"
  ]
  key_pair = opentelekomcloud_compute_keypair_v2.consul_pub.id
  region = var.region
  availability_zone = "${var.region}-01"
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.consul_subnet.id
  }
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "consul_eip" {
  floating_ip = var.public_ip
  instance_id = opentelekomcloud_compute_instance_v2.consul_host.id
}
