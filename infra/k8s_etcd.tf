resource "local_file" "etcd_service" {
  count = var.controller_instances

  content = templatefile("etcd/etcd.sh.tftpl", {
    etcd_name    = aws_instance.controller.*.public_dns[count.index],
    internal_ip  = aws_instance.controller.*.private_ip[count.index],
    etcd_version = var.etcd_version
    etcd_server = join(",", [
      for k, v in zipmap(aws_instance.controller.*.public_dns, aws_instance.controller.*.private_ip) :
      "${k}=https://${v}:2380"
    ])
  })

  filename = "./etcd/generated/controller${count.index}.etcd.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_instance_etcd" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_ca,
    null_resource.k8s_apiserver,
    local_file.etcd_service,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./etcd/generated/controller${count.index}.etcd.sh"
    destination = "etcd.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x etcd.sh",
      "sudo ./etcd.sh"
    ]
  }
}
