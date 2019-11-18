# Create volume
resource "opentelekomcloud_blockstorage_volume_v2" "iSCSI-volume" {
  name = "scsi-volume"
  size = var.disc_volume
  volume_type = var.volume_type
  device_type = "SCSI"
}

# Attach volumes to instance
resource "opentelekomcloud_blockstorage_volume_attach_v2" "attach-iSCSI-volume" {
  count = var.nodes_count
  volume_id   = opentelekomcloud_blockstorage_volume_v2.iSCSI-volume.id
  device     = "auto"
  host_name  = "basic_${count.index}"
  ip_address = "${var.net_address}.${count.index + 10}"

}

