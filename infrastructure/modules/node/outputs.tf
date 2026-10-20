# Public IP per node, used by talosctl and kubectl
output "public_ips" {
  description = "Map of node name to public IP"
  value       = { for name, node in aws_instance.this : name => node.public_ip }
}

# Private IP per node, used for traffic inside the VPC
output "private_ips" {
  description = "Map of node name to private IP"
  value       = { for name, node in aws_instance.this : name => node.private_ip }
}
