# Remote state in S3, settings come from environments/<env>.backend.hcl
terraform {
  backend "s3" {}
}
