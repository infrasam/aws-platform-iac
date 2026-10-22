# Talos version the cluster was created with, never change after creation
variable "talos_version" {
  description = "Talos version contract used to generate secrets and config, e.g. v1.14.4"
  type        = string
}
