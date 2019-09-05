# Acces group, open input port 80, 443 and ssh port
resource "opentelekomcloud_compute_secgroup_v2" "http_https_ssh" {
  description = "Allow external connections to ssh, http, and https ports"
  name = "scn1_public"

  rule {
    cidr = "0.0.0.0/0"
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
  }
  rule {
    cidr = "0.0.0.0/0"
    from_port = 443
    ip_protocol = "tcp"
    to_port = 443
  }
  rule {
    cidr = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
  }
  rule {
    cidr = "0.0.0.0/0"
    from_port = 2210
    ip_protocol = "tcp"
    to_port = 2210
  }
  rule {
    cidr = "0.0.0.0/0"
    from_port = 2211
    ip_protocol = "tcp"
    to_port = 2211
  }
}

resource "opentelekomcloud_compute_secgroup_v2" "local_only" {
  description = "Security group with only local access"
  name = "local_only"
}
