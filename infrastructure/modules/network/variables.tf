# Prefix for resource names, e.g. aws-platform-iac-dev
variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

# IP range for the VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
