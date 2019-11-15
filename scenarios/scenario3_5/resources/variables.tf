variable "volume_type" { default = "SATA" }
variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
variable "debian_image" {}
variable "nodes_count" {}
variable "default_flavor" {}
variable "disc_volume" {}
variable "subnet" {}
variable "prefix" {}
variable "default_az" {}
variable "net_address" {}
