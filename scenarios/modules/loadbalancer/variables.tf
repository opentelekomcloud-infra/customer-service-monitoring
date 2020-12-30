variable "scenario" {}
variable "subnet_id" {}
variable "workspace_prefix" {}
variable "lb_local_ip" {}
variable "monitor_delay" { default = 1 }
variable "monitor_timeout" { default = 1 }
variable "monitor_max_retries" { default = 2 }
variable "protocol" { default = "TCP" }
variable "protocol_port" { default = 80 }
variable "pool_lb_method" { default = "ROUND_ROBIN" }
variable "instances" {}
