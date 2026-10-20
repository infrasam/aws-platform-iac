# Public IP per node, printed after apply
output "node_public_ips" {
  description = "Map of node name to public IP"
  value       = module.node.public_ips
}
