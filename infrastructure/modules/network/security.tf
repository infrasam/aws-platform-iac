# Firewall shared by all cluster nodes
resource "aws_security_group" "cluster" {
  name        = "${var.name_prefix}-sg-cluster"
  description = "Talos cluster nodes"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-sg-cluster"
  }
}

# Nodes may talk freely to each other (etcd, kubelet, pod network)
resource "aws_vpc_security_group_ingress_rule" "cluster_internal" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  ip_protocol                  = "-1"
  description                  = "All traffic between cluster nodes"
}

# Talos API from admin IPs, used by talosctl
resource "aws_vpc_security_group_ingress_rule" "talos_api" {
  for_each = toset(var.admin_cidrs)

  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 50000
  to_port           = 50000
  description       = "Talos API from admin"
}

# Kubernetes API from admin IPs, used by kubectl
resource "aws_vpc_security_group_ingress_rule" "kubernetes_api" {
  for_each = toset(var.admin_cidrs)

  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  description       = "Kubernetes API from admin"
}

# Nodes may reach anything outbound (images, updates, AWS APIs)
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All outbound traffic"
}
