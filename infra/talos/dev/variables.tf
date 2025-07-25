variable "pve_endpoint" {
  description = "endpoint of pve cluster lead"
  type        = string
}


variable "password" {
  description = "pve node password"
  type        = string
  sensitive   = true
}

variable "auth_key" {
  description = "auth key for tailscale"
  type        = string
  sensitive   = true
}
variable "node_network" {
  description = "The IP network of the cluster nodes"
  type        = string
  default     = "10.3.3.0/24"
}


variable "load_balancer_start" {
  description = "The hostnum of the first load balancer host"
  type        = number
  default     = 40
}

variable "load_balancer_stop" {
  description = "The hostnum of the last load balancer host"
  type        = number
  default     = 49
}
