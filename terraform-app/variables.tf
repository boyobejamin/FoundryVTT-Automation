variable "project" {
  default = "ttrpg"
}

variable "environment" {
  default = "bwelch-demo"
}

variable "bootstrap" {
  description = "Name of bootstrap environment for reuse of services"
  default     = "bwelch-demo"
}

variable "owner" {
  default = "bwelch"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "domain" {
  default = "jelly.dev"
}