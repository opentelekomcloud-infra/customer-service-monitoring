# Create volumes
resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az1" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[0].name}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[0]
}

# Attach volumes to instance in az1
resource "opentelekomcloud_compute_volume_attach_v2" "attach_az1_sata" {
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach_az1_sas" {
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach_az1_sata
  ]
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach_az1_ssd" {
  instance_id = opentelekomcloud_compute_instance_v2.http[0].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az1[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach_az1_sas
  ]
}

resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az2" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[1].name}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[1]
}

# Attach volumes to instance in az2
resource "opentelekomcloud_compute_volume_attach_v2" "attach_az2_sata" {
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach_az2_sas" {
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach_az2_sata
  ]
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach_az2_ssd" {
  instance_id = opentelekomcloud_compute_instance_v2.http[1].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az2[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach_az2_sas
  ]
}

resource "opentelekomcloud_blockstorage_volume_v2" "volumes_az3" {
  count             = 3
  name              = "vol-${var.volume_types[count.index]}_${opentelekomcloud_compute_instance_v2.http[2].name}"
  size              = 2
  volume_type       = var.volume_types[count.index]
  availability_zone = var.availability_zones[2]
}

# Attach volumes to instance in az3
resource "opentelekomcloud_compute_volume_attach_v2" "attach_az3_sata" {
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach_az3_sas" {
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach_az3_sata
  ]
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach_az3_ssd" {
  instance_id = opentelekomcloud_compute_instance_v2.http[2].id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes_az3[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach_az3_sas
  ]
}
