terraform {
  # Minimum Terraform version this module supports
  required_version = ">= 1.16"

  required_providers {
    aws = {
      # Minimum provider version, the calling stack pins the exact one
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
