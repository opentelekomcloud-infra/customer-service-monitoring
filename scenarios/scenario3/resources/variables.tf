variable "bastion_vm_id" {}
variable "volume_type" {
  type    = list(string)
  default = ["SATA", "SAS", "SSD"]
}
