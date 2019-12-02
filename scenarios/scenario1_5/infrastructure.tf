
locals {
  key_pair = {
    public_key = var.public_key
    key_name   = "kp_${var.scenario}"
  }
}

module "infrastructure" {
  source = "../scenario1"

  availability_zone = var.availability_zone
  domain_name       = var.domain_name
  ecs_flavor        = var.ecs_flavor
  ecs_image         = var.ecs_image
  public_key        = var.public_key

  username = var.username
  password = var.password

  scenario     = var.scenario
  region      = var.region
  tenant_name = var.tenant_name
}

output "out-scn1_5_lb_fip" {
  value = module.infrastructure.out-scn1_lb_fip
}

output "out-scn1_5_bastion_fip" {
  value = module.infrastructure.out-scn1_bastion_fip
}
