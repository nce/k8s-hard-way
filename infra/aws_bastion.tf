resource "aws_eip" "bastion" {
  vpc = true
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

resource "aws_instance" "bastion" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.rhel.id

  key_name = aws_key_pair.ugo.key_name

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet["eu-central-1a"].id
  availability_zone           = aws_subnet.subnet["eu-central-1a"].availability_zone

  vpc_security_group_ids = [aws_security_group.bastion.id]

  root_block_device {
    volume_size           = 10
    delete_on_termination = true
  }

  depends_on = [aws_internet_gateway.vpc]
}

resource "null_resource" "k8s_bastion_baseos" {

  depends_on = [
    aws_instance.bastion
  ]

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./baseos/baseos.sh"
    destination = "baseos.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x baseos.sh",
      "sudo ./baseos.sh"
    ]
  }
}
