variable "pve_endpoint" {
  description = "endpoint of pve cluster lead"
  type        = string
}


variable "password" {
  description = "pve node password"
  type        = string
  sensitive   = true
}

