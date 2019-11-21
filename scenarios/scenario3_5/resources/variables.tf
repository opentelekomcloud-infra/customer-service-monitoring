variable "volume_type" { default = "SATA" }
variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
variable "ecs_image" {}
variable "ecs_flavor" {}
variable "disc_volume" {}
variable "subnet" {}
variable "network" {}
variable "prefix" {}
variable "availability_zone" {}
variable "net_address" {}
