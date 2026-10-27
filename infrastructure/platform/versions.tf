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
