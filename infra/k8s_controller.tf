resource "local_file" "k8s_service" {
  count = var.controller_instances

  content = templatefile("controller/10-kubernetes.sh.tftpl", {
    k8s_version          = var.k8s_version
    controller_instances = var.controller_instances
    etcd_server          = "https://${join(":2379,https://", aws_instance.controller.*.private_ip)}:2379"
    cluster_public_ip    = aws_instance.bastion.public_ip
    cluster_service_ip   = var.cluster_service_ip
  })

  filename = "./controller/generated/controller${count.index}.10-kubernetes.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_instance_controller" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_ca,
    null_resource.k8s_apiserver,
    null_resource.k8s_service_account,
    null_resource.k8s_controller_manager,
    null_resource.k8s_scheduler,
    local_file.k8s_service,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./controller/generated/controller${count.index}.10-kubernetes.sh"
    destination = "10-kubernetes.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x 10-kubernetes.sh",
      "sudo ./10-kubernetes.sh"
    ]
  }
}
