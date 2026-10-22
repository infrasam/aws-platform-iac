# Talos version the cluster was created with, never change after creation
variable "talos_version" {
  description = "Talos version contract used to generate secrets and config, e.g. v1.14.4"
  type        = string
}

# Cluster name, shown in kubeconfig and talosconfig
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

# Kubernetes API address, e.g. https://1.2.3.4:6443
variable "cluster_endpoint" {
  description = "URL of the Kubernetes API"
  type        = string
}

# Control plane nodes: node name => IP reachable from where Terraform runs
variable "control_plane_nodes" {
  description = "Map of control plane node name to IP"
  type        = map(string)
}
