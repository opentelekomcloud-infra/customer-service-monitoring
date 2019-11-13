# Create volume
resource "opentelekomcloud_blockstorage_volume_v2" "scsi-volume" {
  name = "scsi-volume"
  size = 4
  volume_type = var.volume_type
  device_type = "SCSI"
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-scsi-volume" {
  instance_id = var.bastion_vm_id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.scsi-volume.id
}

