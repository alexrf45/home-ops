variable "env" {
  description = "environment where kubernetes resources reside"
  type        = string
  default     = "dev"
}

variable "username" {
  description = "username for basic auth"
  type        = string
  default     = "fr3d"
}

variable "token" {
  description = "clouflare token"
  sensitive   = true
}
