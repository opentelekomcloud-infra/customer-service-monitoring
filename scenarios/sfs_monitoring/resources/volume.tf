
data  "opentelekomcloud_kms_key_v1" "kms_key" {
  key_alias = var.kms_key_name
}

resource "opentelekomcloud_sfs_file_system_v2" "sharefile" {
  name         = var.scenario
  size         = 20
  access_to    = var.router_id
  access_level = "rw"
  description  = "sfs kms key"
  metadata = {
    "type" = "nfs"
    "#sfs_crypt_key_id" : data.opentelekomcloud_kms_key_v1.kms_key.id,
    "#sfs_crypt_domain_id" : data.opentelekomcloud_kms_key_v1.kms_key.domain_id,
    "#sfs_crypt_alias" : data.opentelekomcloud_kms_key_v1.kms_key.key_alias
  }
}

output "sfs" {
  value = opentelekomcloud_sfs_file_system_v2.sharefile.export_location
}
