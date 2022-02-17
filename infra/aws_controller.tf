resource "aws_instance" "controller" {
  count = var.controller_instances

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

  vpc_security_group_ids      = [aws_security_group.controller.id]
  associate_public_ip_address = true

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
  part {
    filename     = "30-etcd.sh"
    content_type = "text/x-shellscript"
    content = templatefile("cloudinit/30-etcd.sh", {
      etcd_version = var.etcd_version,
    })
  }

  part {
    filename     = "30-kubernetes.sh"
    content_type = "text/x-shellscript"
    content = templatefile("cloudinit/35-kubernetes.sh", {
      k8s_version          = var.k8s_version,
      cluster_service_ip   = var.cluster_service_ip,
      controller_instances = var.controller_instances,
      cluster_public_ip    = aws_instance.bastion.public_ip,
      # TODO: cycle dep resolven
      etcd_server_ips = "https://${join(":2379,https://", aws_instance.controller.*.private_ip)}:2379"
    })
  }
}
