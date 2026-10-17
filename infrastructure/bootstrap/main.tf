# Current AWS account, used to make the bucket name globally unique
data "aws_caller_identity" "current" {}

locals {
  # Prefix for all resource names, e.g. aws-platform-iac-dev
  name_prefix = "${var.project}-${var.environment}"
}

# Bucket that stores Terraform state for all stacks
resource "aws_s3_bucket" "state" {
  bucket = "${local.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Refuse to delete the bucket, losing it means losing all state
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${local.name_prefix}-tfstate"
  }
}

# Keep every previous version of each state file
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest with S3-managed keys
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block every form of public access
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Reject any request that is not encrypted in transit (plain HTTP)
resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}

# Delete old state versions after 90 days to keep storage small
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  # Versioning must exist before rules about old versions
  depends_on = [aws_s3_bucket_versioning.state]
}
