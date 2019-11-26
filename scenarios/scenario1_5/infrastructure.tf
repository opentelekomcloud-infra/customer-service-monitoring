
locals {
  key_pair = {
    public_key = var.public_key
    key_name   = "kp_${var.postfix}"
  }
}

module "infrastructure" {
  source = "../scenario1"

  availability_zone = var.availability_zone
  bastion_eip       = var.bastion_eip
  loadbalancer_eip  = var.loadbalancer_eip
  domain_name       = var.domain_name
  ecs_flavor        = var.ecs_flavor
  ecs_image         = var.ecs_image
  public_key        = var.public_key

  username = var.username
  password = var.password

  postfix     = var.postfix
  region      = var.region
  tenant_name = var.tenant_name
}

output "out-scn1_5_lb_fip" {
  value = var.loadbalancer_eip
}

output "out-scn1_5_bastion_fip" {
  value = var.bastion_eip
}

