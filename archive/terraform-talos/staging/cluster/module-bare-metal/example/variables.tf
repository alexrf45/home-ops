variable "password" {
  description = "pve node password"
  type        = string
  sensitive   = true
}
variable "cert-manager-manifest" {
  description = "url of cert-manager manifest"
  default     = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"
}

variable "node_network" {
  description = "The IP network of the cluster nodes"
  type        = string
  default     = "10.3.3.0/24"
}


variable "load_balancer_start" {
  description = "The hostnum of the first load balancer host"
  type        = number
  default     = 70
}

variable "load_balancer_stop" {
  description = "The hostnum of the last load balancer host"
  type        = number
  default     = 150
}
