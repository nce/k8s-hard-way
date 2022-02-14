resource "aws_instance" "bastion" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.rhel.id

  key_name = aws_key_pair.ugo.key_name

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet["eu-central-1a"].id
  availability_zone           = aws_subnet.subnet["eu-central-1a"].availability_zone

  vpc_security_group_ids = [aws_security_group.bastion.id]

  user_data = data.cloudinit_config.bastion.rendered

  root_block_device {
    volume_size           = 10
    delete_on_termination = true
  }

  depends_on = [aws_internet_gateway.vpc]
}

data "cloudinit_config" "bastion" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "10-baseos.sh"
    content_type = "text/x-shellscript"
    content      = file("cloudinit/10-baseos.sh")
  }

  part {
    filename     = "99-kickstart.yaml"
    content_type = "text/cloud-config"
    content      = file("cloudinit/99-kickstart-bastion.yaml")
  }

}
