# Cluster-wide secrets: certificates and tokens, generated once and kept in state
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# Machine config for control plane nodes, generated from the secrets
data "talos_machine_configuration" "control_plane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

# Send the machine config to each control plane node over the Talos API
resource "talos_machine_configuration_apply" "control_plane" {
  for_each = var.control_plane_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = each.value

  config_patches = [
    # Disk Talos installs itself on
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "UnattendedInstallConfig"
      provisioning = {
        diskSelector = {
          match = "disk.dev_path == \"/dev/nvme0n1\""
        }
      }
    }),
    # Single node cluster: remove the control plane taint so normal workloads can run here
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "KubeNodeConfig"
      taints = {
        "$patch" = "delete"
      }
    }),
  ]
}

locals {
  # First control plane node, used for bootstrap and to fetch the kubeconfig
  first_control_plane = values(var.control_plane_nodes)[0]
}

# Start etcd and Kubernetes, done once in the cluster's life on the first node
resource "talos_machine_bootstrap" "this" {
  node                 = local.first_control_plane
  client_configuration = talos_machine_secrets.this.client_configuration

  # The node must have its config before it can be bootstrapped
  depends_on = [talos_machine_configuration_apply.control_plane]
}

# Admin kubeconfig for kubectl, fetched after bootstrap
resource "talos_cluster_kubeconfig" "this" {
  node                 = local.first_control_plane
  client_configuration = talos_machine_secrets.this.client_configuration

  # Kubernetes must be running before a kubeconfig can be fetched
  depends_on = [talos_machine_bootstrap.this]
}

# Admin talosconfig for talosctl
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = values(var.control_plane_nodes)
  nodes                = values(var.control_plane_nodes)
}
