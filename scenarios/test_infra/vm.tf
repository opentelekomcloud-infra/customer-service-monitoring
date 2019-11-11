data "opentelekomcloud_images_image_v2" "base_image" {
  name        = var.image_name
  most_recent = true
  visibility  = var.image_visibility
}

resource opentelekomcloud_compute_keypair_v2 "th_kp" {
  name       = "${local.prefix}-kp"
  public_key = var.public_key
}

resource "opentelekomcloud_compute_instance_v2" "test_host" {
  name              = "${local.prefix}-ecs"
  image_id          = data.opentelekomcloud_images_image_v2.base_image.id
  flavor_name       = var.flavour
  key_pair          = opentelekomcloud_compute_keypair_v2.th_kp.name
  region            = var.region
  availability_zone = var.default_az
  security_groups = [
    opentelekomcloud_compute_secgroup_v2.group.name
  ]
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
}
