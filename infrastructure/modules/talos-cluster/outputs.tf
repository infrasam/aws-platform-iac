# Kubeconfig for kubectl, a secret
output "kubeconfig" {
  description = "Admin kubeconfig for the cluster"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

# Talosconfig for talosctl, a secret
output "talosconfig" {
  description = "Admin talosconfig for the cluster"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}
