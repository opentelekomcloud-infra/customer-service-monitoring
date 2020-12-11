module "resources" {
  source = "./resources"

  ecs_image                   = var.ecs_image
  initiator_availability_zone = var.initiator_availability_zone
  target_availability_zone    = var.target_availability_zone
  ecs_flavor                  = var.ecs_flavor
  disc_volume                 = var.disc_volume
  key_pair_name               = local.key_pair.key_name


  net_address = var.addr_3_octets
  subnet      = module.network.subnet
  network     = module.network.network
  router      = module.network.router
  scenario    = var.scenario
}

output "scn3_5_initiator_instance_ip" {
  value = module.resources.initiator_instance_ip
}

output "scn3_5_target_instance_ip" {
  value = module.resources.target_instance_ip
}

output "scn3_5_sfs_data" {
  value = module.resources.sfs
}
