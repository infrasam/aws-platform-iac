# Official Talos Linux image for ARM, published by Sidero Labs
data "aws_ami" "talos" {
  owners      = ["540036508848"]
  most_recent = true

  filter {
    name   = "name"
    values = ["talos-${var.talos_version}-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# One EC2 instance per node
resource "aws_instance" "this" {
  for_each = var.nodes

  ami                    = data.aws_ami.talos.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[each.value]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  # Only allow the secure version of the metadata service (IMDSv2)
  # Hop limit 2 lets pods reach it through the container network
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }


  # Encrypted system disk
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  # Talos is upgraded with talosctl, not by replacing the machine
  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "${var.name_prefix}-node-${each.key}"
  }
}

# Fixed public IP per node, survives stop and start
resource "aws_eip" "this" {
  for_each = var.nodes

  instance = aws_instance.this[each.key].id
  domain   = "vpc"

  tags = {
    Name = "${var.name_prefix}-eip-${each.key}"
  }
}
