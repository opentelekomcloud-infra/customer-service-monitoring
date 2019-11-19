
resource "opentelekomcloud_dns_zone_v2" "private_zone" {
  name        = var.dns_private_zone
  description = "Private DNS for scenario 1"
  ttl         = 600
  type        = "private"
  router {
    router_id     = var.router_id
    router_region = var.region
  }
}

locals {
  full_bastion_name = "${var.dns_bastion_record}.${var.dns_private_zone}"
}

resource "opentelekomcloud_dns_recordset_v2" "bastion" {
  name    = local.full_bastion_name
  type    = "A"
  ttl     = 300
  records = [var.bastion_local_ip]
  zone_id = opentelekomcloud_dns_zone_v2.private_zone.id
}

output "bastion_dns" {
  value = local.full_bastion_name
}
