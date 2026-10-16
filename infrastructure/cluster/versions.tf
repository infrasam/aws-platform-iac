terraform {
  # Minimum Terraform version this code requires
  required_version = ">= 1.14"

  required_providers {
    aws = {
      # Where the provider is downloaded from
      source = "hashicorp/aws"
      # Allowed provider versions
      version = "~> 6.69"
    }
  }
}

# AWS connection settings
provider "aws" {
  region  = "eu-north-1"
  profile = "lab"
}
