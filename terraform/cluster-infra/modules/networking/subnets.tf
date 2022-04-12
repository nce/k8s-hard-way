locals {
  public_cidr  = cidrsubnet(var.aws_vpc_cidr, 1, 0)
  private_cidr = cidrsubnet(var.aws_vpc_cidr, 1, 1)
}

variable "az_mapping" {
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zone" "all" {
  for_each = toset(data.aws_availability_zones.available.names)

  name = each.key
}

resource "aws_subnet" "public" {
  for_each = data.aws_availability_zone.all

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(local.public_cidr, 3, var.az_mapping[each.value.name_suffix])

  tags = {
    Name                                            = "${var.k8s_cluster_name}-public"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.k8s_cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private" {
  for_each = data.aws_availability_zone.all

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(local.private_cidr, 3, var.az_mapping[each.value.name_suffix])

  tags = {
    Name                                            = "${var.k8s_cluster_name}-private"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.k8s_cluster_name}" = "owned"
  }
}
