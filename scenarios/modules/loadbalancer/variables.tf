variable "scenario" {}
variable "subnet_id" {}
variable "loadbalancer_local_ip" {}
variable "workspace_prefix" {}
variable "nodes_count" {}
variable "net_address" {}
variable "monitor_delay" { default = 1 }
variable "monitor_timeout" { default = 1 }
variable "monitor_max_retries" { default = 2 }
variable "pool_protocol" { default = "TCP" }
variable "pool_lb_method" { default = "ROUND_ROBIN" }
variable "instances" {}
