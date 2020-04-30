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

resource "opentelekomcloud_kms_key_v1" "sfs_key" {
  key_alias       = "sfs_key_${var.scenario}"
  pending_days    = "7"
  key_description = "sfs kms key"
  is_enabled      = true
}

resource "opentelekomcloud_sfs_file_system_v2" "sharefile" {
  size = 20
  name = "sfs_${var.scenario}"
  access_to = var.network.id
  access_level = "rw"
  description = "sfs with kms encryption"
  metadata = {
    "type"="nfs"
     "#sfs_crypt_key_id": opentelekomcloud_kms_key_v1.sfs_key.id,
     "#sfs_crypt_domain_id": opentelekomcloud_kms_key_v1.sfs_key.domain_id,
     "#sfs_crypt_alias": opentelekomcloud_kms_key_v1.sfs_key.key_alias
  }
}

output "sfs" {
  value = opentelekomcloud_sfs_file_system_v2.sharefile
}