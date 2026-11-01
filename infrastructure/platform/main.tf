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

# Argo CD, installed once by Terraform and managed with GitOps from then on
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
}

# GitOps Bridge: registers the cluster in Argo CD and hands infrastructure facts to ApplicationSets
resource "kubernetes_secret_v1" "cluster" {
  metadata {
    name      = "in-cluster"
    namespace = helm_release.argocd.namespace

    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      environment                      = var.environment
    }

    annotations = {
      aws_region   = var.region
      aws_vpc_id   = data.terraform_remote_state.cluster.outputs.vpc_id
      cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
    }
  }

  data = {
    name   = "in-cluster"
    server = "https://kubernetes.default.svc"
    config = jsonencode({ tlsClientConfig = { insecure = false } })
  }
}

# Root Application: points Argo CD at the GitOps repository, everything else is defined there
resource "helm_release" "bootstrap" {
  name      = "bootstrap"
  namespace = helm_release.argocd.namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version

  values = [yamlencode({
    applications = {
      bootstrap = {
        namespace = helm_release.argocd.namespace
        project   = "default"
        source = {
          repoURL        = var.gitops_repo_url
          targetRevision = "main"
          path           = "bootstrap"
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = helm_release.argocd.namespace
        }
        syncPolicy = {
          automated = {
            prune    = true
            selfHeal = true
          }
        }
      }
    }
  })]

  # The cluster must be registered before the ApplicationSets look for it
  depends_on = [kubernetes_secret_v1.cluster]
}
