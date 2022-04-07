resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id     = aws_eip.eip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[data.aws_availability_zones.available.names[0]].id

  depends_on = [
    aws_internet_gateway.vpc
  ]
}
