# Create volume
resource "opentelekomcloud_blockstorage_volume_v2" "iSCSI-volume" {
  name = "scsi-volume"
  size = 10
  volume_type = var.volume_type
  device_type = "SCSI"
}

# Attach volumes to instance
resource "opentelekomcloud_blockstorage_volume_attach_v2" "attach-iSCSI-volume" {
  volume_id   = opentelekomcloud_blockstorage_volume_v2.iSCSI-volume.id
  device     = "auto"
  host_name  = ""
  ip_address = ""
}

