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
}

resource "local_file" "etcd_service" {
  count = var.controller_instances

  content = templatefile("etcd/10-etcd.sh.tftpl", {
    etcd_name    = aws_instance.controller.*.public_dns[count.index],
    internal_ip  = aws_instance.controller.*.private_ip[count.index],
    etcd_version = var.etcd_version
    etcd_server  = join(",", [for k, v in zipmap(aws_instance.controller.*.public_dns, aws_instance.controller.*.private_ip) : "${k}=https://${v}:2380"])
  })

  filename = "./etcd/controller${count.index}.10-etcd.sh"
}

resource "null_resource" "k8s_instance_etcd" {
  count = var.controller_instances

  depends_on = [null_resource.k8s_ca, null_resource.k8s_apiserver]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./etcd/controller${count.index}.10-etcd.sh"
    destination = "10-etcd.sh"
  }

  provisioner "remote-exec" {


    inline = [
      "sudo chmod +x 10-etcd.sh",
      "sudo ./10-etcd.sh"
      #"sudo ETCDCTL_API=3 etcdctl member list --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.pem --cert=/etc/etcd/kubernetes.pem --key=/etc/etcd/kubernetes-key.pem",
    ]

  }
}
#  part {
#    filename     = "30-kubernetes.sh"
#    content_type = "text/x-shellscript"
#    content = templatefile("cloudinit/35-kubernetes.sh", {
#      k8s_version          = var.k8s_version,
#      cluster_service_ip   = var.cluster_service_ip,
#      controller_instances = var.controller_instances,
#      cluster_public_ip    = aws_instance.bastion.public_ip,
#      # TODO: cycle dep resolven
#      etcd_server_ips = "https://${join(":2379,https://", aws_instance.controller.*.private_ip)}:2379"
#    })
#  }
#}
