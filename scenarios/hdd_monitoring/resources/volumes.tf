# Create volumes
resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az1" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[0].name}_${local.workspace_prefix}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[0]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach_az1" {
  count       = length(opentelekomcloud_blockstorage_volume_v2.volumes_az1)
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[count.index].id
}

resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az2" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[1].name}_${local.workspace_prefix}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[1]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach_az2" {
  count       = length(opentelekomcloud_blockstorage_volume_v2.volumes_az2)
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[count.index].id
}

resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az3" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[2].name}_${local.workspace_prefix}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[2]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach_az3" {
  count       = length(opentelekomcloud_blockstorage_volume_v2.volumes_az3)
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[count.index].id
}
