# Outputs from the cluster stack, read from its state in S3
data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket  = var.state_bucket
    key     = "cluster/${var.environment}.tfstate"
    region  = var.region
    profile = "lab"
  }
}

locals {
  # Admin kubeconfig from the cluster stack, split into the parts the providers need
  kubeconfig = yamldecode(data.terraform_remote_state.cluster.outputs.kubeconfig)
  cluster    = local.kubeconfig.clusters[0].cluster
  user       = local.kubeconfig.users[0].user
}

# Temporary check that the providers can reach the cluster
data "kubernetes_namespace_v1" "kube_system" {
  metadata {
    name = "kube-system"
  }
}
