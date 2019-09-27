variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
variable "name" {
  default = "bastion"
}
variable "default_flavor" {}
variable "debian_image" {}
variable "bastion_eip" {}
variable "network" {}
variable "subnet" {}
variable "router" {}
variable "volume_bastion" {
  type    = number
  default = 10
}

variable "bastion_local_ip" {
  default = ""
}
