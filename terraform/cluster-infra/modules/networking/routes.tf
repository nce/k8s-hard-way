resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each = data.aws_availability_zone.all

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = data.aws_availability_zone.all

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}
