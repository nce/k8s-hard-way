resource "aws_vpc" "vpc" {
  cidr_block = var.main_vpc_cidr

  assign_generated_ipv6_cidr_block = true

  enable_dns_hostnames = true
  enable_dns_support   = true

}

resource "aws_internet_gateway" "vpc" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route" "internet" {
  route_table_id         = aws_default_route_table.vpc.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc.id
}

# setup az <-> subnet mapping
variable "region_mapping" {
  default = {
    eu-central-1 = 1
  }
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

resource "aws_subnet" "subnet" {
  for_each = data.aws_availability_zone.all

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, var.az_mapping[each.value.name_suffix])
}

resource "aws_route" "pod_routing" {
  count = var.worker_instances

  route_table_id         = aws_vpc.vpc.default_route_table_id
  destination_cidr_block = "10.200.${count.index + var.controller_instances}.0/24"
  network_interface_id   = aws_instance.worker[count.index].primary_network_interface_id
}

resource "aws_route" "pod_routing_controller" {
  count = var.controller_instances

  route_table_id         = aws_vpc.vpc.default_route_table_id
  destination_cidr_block = "10.200.${count.index}.0/24"
  network_interface_id   = aws_instance.controller[count.index].primary_network_interface_id
}
