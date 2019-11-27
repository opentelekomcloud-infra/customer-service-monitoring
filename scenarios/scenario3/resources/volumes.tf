# Create volume
resource "opentelekomcloud_blockstorage_volume_v2" "volumes" {
  count       = 3
  name        = format("vol-%s", var.volume_type[count.index])
  size        = 2
  volume_type = var.volume_type[count.index]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-0" {
  instance_id = var.bastion_vm_id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-1" {
  instance_id = var.bastion_vm_id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-0
  ]
}
resource "opentelekomcloud_compute_volume_attach_v2" "attach-2" {
  instance_id = var.bastion_vm_id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-1
  ]
}
