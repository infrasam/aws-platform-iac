# Settings for the dev environment
environment  = "dev"
region       = "eu-north-1"
state_bucket = "aws-platform-iac-dev-tfstate-271825827554"

# Argo CD Helm chart
# renovate: datasource=helm depName=argo-cd registryUrl=https://argoproj.github.io/argo-helm
argocd_chart_version = "10.18.0"

# Bootstrap: where Argo CD finds everything else
# renovate: datasource=helm depName=argocd-apps registryUrl=https://argoproj.github.io/argo-helm
argocd_apps_chart_version = "2.0.7"
gitops_repo_url           = "https://github.com/infrasam/aws-platform-gitops.git"
