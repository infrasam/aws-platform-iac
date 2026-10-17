# Settings for the dev environment
project     = "aws-platform-iac"
environment = "dev"
region      = "eu-north-1"
vpc_cidr    = "10.0.0.0/16"

# One public subnet per availability zone
public_subnets = {
  a = "10.0.0.0/24"
  b = "10.0.1.0/24"
  c = "10.0.2.0/24"
}
