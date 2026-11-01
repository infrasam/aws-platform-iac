# Settings for the dev environment
environment  = "dev"
region       = "eu-north-1"
state_bucket = "aws-platform-iac-dev-tfstate-271825827554"

# Argo CD Helm chart, app version v3.5.6
argocd_chart_version = "10.11.6"

# Bootstrap: where Argo CD finds everything else
argocd_apps_chart_version = "2.0.7"
gitops_repo_url           = "https://github.com/infrasam/aws-platform-gitops.git"
