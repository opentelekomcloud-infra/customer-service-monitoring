
resource "opentelekomcloud_vpc_v1" "vpc" {
  cidr = "192.168.0.0/28"
  name = "${local.prefix}_vpc"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  cidr          = "192.168.0.0/29"
  gateway_ip    = "192.168.0.1"
  name          = "${local.prefix}_subnet"
  vpc_id        = opentelekomcloud_vpc_v1.vpc.id
  primary_dns   = "1.1.1.1"
  secondary_dns = "8.8.8.8"
}

resource "opentelekomcloud_compute_secgroup_v2" "public_ssh" {
  description = "Public ssh port"
  name        = "public_ssh"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}
