locals {
  # Prefix for all resource names, e.g. aws-platform-iac-dev
  name_prefix = "${var.project}-${var.environment}"
}

# Isolated network for the cluster
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

