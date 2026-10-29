terraform {
  # Minimum Terraform version this code requires
  required_version = ">= 1.16"

  required_providers {
    helm = {
      # Installs Helm charts such as Argo CD
      source = "hashicorp/helm"
      # Allowed provider versions
      version = "~> 3.3"
    }
    kubernetes = {
      # Manages Kubernetes objects such as the Argo CD cluster secret
      source = "hashicorp/kubernetes"
      # Allowed provider versions
      version = "~> 3.4"
    }
  }
}

# Kubernetes connection, built from the cluster stack's kubeconfig
provider "kubernetes" {
  host                   = local.cluster.server
  cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.user["client-certificate-data"])
  client_key             = base64decode(local.user["client-key-data"])
}

# Helm uses the same Kubernetes connection
provider "helm" {
  kubernetes = {
    host                   = local.cluster.server
    cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.user["client-certificate-data"])
    client_key             = base64decode(local.user["client-key-data"])
  }
}
