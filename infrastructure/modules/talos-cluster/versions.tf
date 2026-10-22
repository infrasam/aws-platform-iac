terraform {
  # Minimum Terraform version this module supports
  required_version = ">= 1.16"

  required_providers {
    talos = {
      # Minimum provider version, the calling stack pins the exact one
      source  = "siderolabs/talos"
      version = ">= 0.12"
    }
  }
}
