# Create SCSI volume
resource "opentelekomcloud_blockstorage_volume_v2" "SCSI-volume" {
  name              = "scsi-volume"
  size              = var.disc_volume
  volume_type       = var.volume_type
  availability_zone = var.target_availability_zone
  device_type       = "SCSI"
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-SCSI-volume" {
  instance_id = opentelekomcloud_compute_instance_v2.target_instance.id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.SCSI-volume.id
}

output "iscsi_device_name" {
  value = opentelekomcloud_compute_volume_attach_v2.attach-SCSI-volume.device
}