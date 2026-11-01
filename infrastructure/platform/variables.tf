# Deployment environment, selects which cluster state to read
variable "environment" {
  description = "Deployment environment"
  type        = string
}

# AWS region of the state bucket
variable "region" {
  description = "AWS region of the state bucket"
  type        = string
}

# Bucket that holds the state of every stack
variable "state_bucket" {
  description = "S3 bucket with Terraform state"
  type        = string
}

# Argo CD Helm chart version
variable "argocd_chart_version" {
  description = "Version of the argo-cd Helm chart"
  type        = string
}

# argocd-apps Helm chart version, used to create the bootstrap Application
variable "argocd_apps_chart_version" {
  description = "Version of the argocd-apps Helm chart"
  type        = string
}

# Git repository that Argo CD syncs everything else from
variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
}
