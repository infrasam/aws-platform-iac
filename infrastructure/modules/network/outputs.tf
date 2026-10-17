# VPC ID, used by other resources such as nodes and security groups
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

# Public subnet IDs per AZ letter, used to place the nodes
output "public_subnet_ids" {
  description = "Map of AZ letter to public subnet ID"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

# Security group ID, attached to every cluster node
output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.cluster.id
}
