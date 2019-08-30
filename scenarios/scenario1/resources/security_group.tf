# Acces group, open input port 80, 443 and ssh port
resource "openstack_compute_secgroup_v2" "http" {
  name          = "http"
  description   = "Open input http port"
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "ssh" {
  name          = "ssh"
  description   = "Open input ssh port"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "https" {
  name          = "http"
  description   = "Open input https port"
  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "opentelekomcloud_compute_secgroup_v2" "local_only" {
  description = "Security group with only local access"
  name = "local_only"
}
