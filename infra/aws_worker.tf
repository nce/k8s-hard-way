resource "aws_instance" "worker" {
  count = var.worker_instances

  instance_type = "t2.medium"
  ami           = data.aws_ami.rhel.id

  key_name = aws_key_pair.ugo.key_name

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

  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30
    delete_on_termination = true
  }

}
