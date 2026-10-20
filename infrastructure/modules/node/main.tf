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

  # Only allow the secure version of the metadata service (IMDSv2)
  metadata_options {
    http_tokens = "required"
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
