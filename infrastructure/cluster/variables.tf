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

# Public IPs allowed to reach the Talos and Kubernetes APIs, set via TF_VAR_admin_cidrs
variable "admin_cidrs" {
  description = "CIDR blocks allowed to reach the Talos and Kubernetes APIs"
  type        = list(string)
}

# Talos version, used to find the matching image
variable "talos_version" {
  description = "Talos Linux version, e.g. v1.14.4"
  type        = string
}

# EC2 size for every node
variable "instance_type" {
  description = "EC2 instance type for the nodes"
  type        = string
}

# Nodes to create: node name => AZ letter
variable "nodes" {
  description = "Map of node name to availability zone letter"
  type        = map(string)
}
