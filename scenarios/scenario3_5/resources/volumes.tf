# Create volume
resource "opentelekomcloud_evs_volume_v3" "iSCSI-volume" {
  name = "scsi-volume"
  size = var.disc_volume
  volume_type = var.volume_type
  multiattach = true
  availability_zone = var.default_az
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-iSCSI-volume" {
  instance_id = opentelekomcloud_compute_instance_v2.instance.*.id[count.index]
  volume_id   = opentelekomcloud_evs_volume_v3.iSCSI-volume.id
}
