# Current account and region, used to build ARNs
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Only EC2 instances may use the node role
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role for the cluster nodes, used by in-cluster controllers such as External Secrets
resource "aws_iam_role" "node" {
  name               = "${var.name_prefix}-node"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Read access to this environment's SSM parameters, nothing else
data "aws_iam_policy_document" "ssm_read" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.name_prefix}/*",
    ]
  }
}

# Attach the SSM read policy to the node role
resource "aws_iam_role_policy" "ssm_read" {
  name   = "ssm-read"
  role   = aws_iam_role.node.id
  policy = data.aws_iam_policy_document.ssm_read.json
}

# Instance profile, the way an EC2 instance carries a role
resource "aws_iam_instance_profile" "node" {
  name = "${var.name_prefix}-node"
  role = aws_iam_role.node.name
}
