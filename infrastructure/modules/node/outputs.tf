# Fixed public IP per node, used by talosctl and kubectl
output "public_ips" {
  description = "Map of node name to Elastic IP"
  value       = { for name, eip in aws_eip.this : name => eip.public_ip }
}

# Private IP per node, used for traffic inside the VPC
output "private_ips" {
  description = "Map of node name to private IP"
  value       = { for name, node in aws_instance.this : name => node.private_ip }
}

# SSM path the node role may read, handed to External Secrets through the GitOps Bridge
output "ssm_parameter_prefix" {
  description = "SSM parameter path for this environment"
  value       = local.ssm_parameter_prefix
}
