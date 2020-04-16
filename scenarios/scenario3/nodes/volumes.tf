# Create volumes
resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az1" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[0].name}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[0]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-az1" {
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-az1-1" {
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-az1
  ]
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-az1-2" {
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-az1-1
  ]
}

resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az2" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[1].name}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[1]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-az2" {
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-az2-1" {
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-az2
  ]
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-az2-2" {
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-az2-1
  ]
}

resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az3" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[2].name}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[2]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-az3" {
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-az3-1" {
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-az3
  ]
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-az3-2" {
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-az3-1
  ]
}