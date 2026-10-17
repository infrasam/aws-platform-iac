locals {
  # Prefix for all resource names, e.g. aws-platform-iac-dev
  name_prefix = "${var.project}-${var.environment}"
}

# Network for the cluster: VPC, subnets, routing and firewall
module "network" {
  source = "../modules/network"

  name_prefix    = local.name_prefix
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  admin_cidrs    = var.admin_cidrs
}

# The VPC moved into the network module, keep it instead of recreating it
moved {
  from = aws_vpc.this
  to   = module.network.aws_vpc.this
}
