# Project name, used in resource names and tags
variable "project" {
  description = "Project name used in resource names and tags"
  type        = string
}

# Deployment environment, only known values allowed
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be dev, stage or prod."
  }
}

# AWS region where all resources are created
variable "region" {
  description = "AWS region for all resources"
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

