# Public IP per node, printed after apply
output "node_public_ips" {
  description = "Map of node name to public IP"
  value       = module.node.public_ips
}

# Kubeconfig for kubectl, saved to a file with make credentials
output "kubeconfig" {
  description = "Admin kubeconfig for the cluster"
  value       = module.talos_cluster.kubeconfig
  sensitive   = true
}

# Talosconfig for talosctl, saved to a file with make credentials
output "talosconfig" {
  description = "Admin talosconfig for the cluster"
  value       = module.talos_cluster.talosconfig
  sensitive   = true
}

# Cluster name, handed over to Argo CD by the platform stack
output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = local.name_prefix
}

# VPC ID, handed over to Argo CD by the platform stack
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}
