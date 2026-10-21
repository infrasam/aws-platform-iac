# Prefix for resource names, e.g. aws-platform-iac-dev
variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
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

# Subnet per AZ letter, from the network module
variable "subnet_ids" {
  description = "Map of AZ letter to subnet ID"
  type        = map(string)
}

# Firewall attached to every node, from the network module
variable "security_group_id" {
  description = "Security group ID for the nodes"
  type        = string
}
