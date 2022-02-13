data "aws_ami" "rhel" {
  # ownerid is redhat
  owners      = ["309956199498"]
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8.*_HVM-*x86_64*"]
  }

}
