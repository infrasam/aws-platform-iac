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

# Public subnets: AZ letter => CIDR block
variable "public_subnets" {
  description = "Map of availability zone letter to subnet CIDR"
  type        = map(string)
}

# Public IPs allowed to reach the Talos and Kubernetes APIs, e.g. ["1.2.3.4/32"]
variable "admin_cidrs" {
  description = "CIDR blocks allowed to reach the Talos and Kubernetes APIs"
  type        = list(string)
}
