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

