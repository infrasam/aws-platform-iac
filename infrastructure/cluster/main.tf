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

# Cluster nodes running Talos Linux
module "node" {
  source = "../modules/node"

  name_prefix       = local.name_prefix
  talos_version     = var.talos_version
  instance_type     = var.instance_type
  nodes             = var.nodes
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.cluster_security_group_id
}

# Talos configuration and Kubernetes bootstrap for the nodes
module "talos_cluster" {
  source = "../modules/talos-cluster"

  talos_version           = var.talos_version
  cluster_name            = local.name_prefix
  control_plane_nodes     = module.node.private_ips
  control_plane_endpoints = module.node.public_ips

  # First node is the API endpoint, several nodes would use a load balancer
  cluster_endpoint = "https://${values(module.node.public_ips)[0]}:6443"
}
