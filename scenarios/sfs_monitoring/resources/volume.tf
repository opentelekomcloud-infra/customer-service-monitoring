resource "opentelekomcloud_kms_key_v1" "sfs_key" {
  key_alias = "sfs_KMS_${var.scenario}"
  pending_days = "7"
  key_description = "sfs kms key"
  is_enabled = true
}

resource "opentelekomcloud_sfs_file_system_v2" "sharefile" {
  name = "${var.scenario}_volume"
  size = 20
  access_to = var.router_id
  access_level = "rw"
  description = "SFS with KMS encryption"
  metadata = {
    "type" = "nfs"
    "#sfs_crypt_key_id": opentelekomcloud_kms_key_v1.sfs_key.id,
    "#sfs_crypt_domain_id": opentelekomcloud_kms_key_v1.sfs_key.domain_id,
    "#sfs_crypt_alias": opentelekomcloud_kms_key_v1.sfs_key.key_alias
  }
}

output "sfs" {
  value = opentelekomcloud_sfs_file_system_v2.sharefile.export_location
}
