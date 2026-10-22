# Cluster-wide secrets: certificates and tokens, generated once and kept in state
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}
