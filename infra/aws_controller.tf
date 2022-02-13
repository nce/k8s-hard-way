resource "aws_instance" "controller" {
  count = var.controller_instances

  instance_type = "t2.medium"
  ami           = data.aws_ami.rhel.id

  key_name = aws_key_pair.ugo.key_name

  associate_public_ip_address = false
  subnet_id = aws_subnet.subnet[
    keys(data.aws_availability_zone.all)[
      (count.index) % length(keys(data.aws_availability_zone.all))
    ]
  ].id
  availability_zone = aws_subnet.subnet[
    keys(data.aws_availability_zone.all)[
      (count.index) % length(keys(data.aws_availability_zone.all))
    ]
  ].availability_zone

  vpc_security_group_ids = [aws_security_group.controller.id]

  user_data = data.cloudinit_config.controller.rendered

  root_block_device {
    volume_size           = 30
    delete_on_termination = true
  }

}

data "cloudinit_config" "controller" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "10-baseos.sh"
    content_type = "text/x-shellscript"
    content      = file("cloudinit/10-baseos.sh")
  }
  part {
    filename     = "20-crio.sh"
    content_type = "text/x-shellscript"
    content      = file("cloudinit/20-crio.sh")
  }

}
