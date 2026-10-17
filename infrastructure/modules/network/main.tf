# Region the provider runs in, used to build AZ names
data "aws_region" "current" {}

# Isolated network for the cluster
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# Gateway that connects the VPC to the internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# One public subnet per availability zone
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = "${data.aws_region.current.region}${each.key}"
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-subnet-public-${each.key}"
  }
}

# Routing for public subnets: all internet traffic goes via the gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-public"
  }
}

# Attach each public subnet to the public route table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
