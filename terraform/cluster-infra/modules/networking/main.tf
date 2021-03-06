resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vpc_cidr

  assign_generated_ipv6_cidr_block = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${var.k8s_cluster_name}" = "owned"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = aws_vpc.vpc.id
}

