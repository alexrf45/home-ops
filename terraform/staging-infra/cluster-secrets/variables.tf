variable "env" {
  description = "environment where kubernetes resources reside"
  type        = string
  default     = "dev"
}

variable "username" {
  description = "username for basic auth"
  type        = string
}

variable "token" {
  description = "clouflare token"
}
