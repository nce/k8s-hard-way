output "public_subnets" {
  value = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "private_subnets" {
  value = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
