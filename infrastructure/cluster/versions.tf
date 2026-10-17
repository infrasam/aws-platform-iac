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
  region  = var.region
  profile = "lab"

  # Tags added automatically to every resource this provider creates
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
