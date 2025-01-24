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

variable "access-key-id" {
  description = "aws access key id"
  type        = string
}

variable "secret-access-key" {
  description = "secret access key"
  type        = string
}
