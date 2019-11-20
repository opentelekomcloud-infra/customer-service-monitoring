# Create SCSI volume
resource "opentelekomcloud_blockstorage_volume_v2" "SCSI-volume" {
  name              = "scsi-volume"
  size              = var.disc_volume
  volume_type       = var.volume_type
  multiattach       = true
  availability_zone = var.default_az
  device_type       = "SCSI"
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-SCSI-volume" {
  instance_id = opentelekomcloud_compute_instance_v2.target_instance
  volume_id   = opentelekomcloud_blockstorage_volume_v2.SCSI-volume.id
}
