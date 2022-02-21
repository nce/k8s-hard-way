resource "local_file" "k8s_worker_kubelet" {
  count = var.worker_instances

  content = templatefile("kubelet/kubelet.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_private_ip = aws_instance.bastion.private_ip
    pod_cidr           = "10.200.0.0/16"
  })

  filename = "./kubelet/generated/worker${count.index}-kubelet.sh"

  depends_on = [aws_instance.worker]
}

resource "null_resource" "k8s_instance_worker" {
  count = var.worker_instances

  depends_on = [
    null_resource.k8s_ca_worker,
    null_resource.k8s_kubelet,
    null_resource.k8s_proxy,
    null_resource.k8s_admin,
    local_file.k8s_worker_kubelet,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./kubelet/generated/worker${count.index}-kubelet.sh"
    destination = "kubelet.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x kubelet.sh",
      "sudo ./kubelet.sh"
    ]
  }
}
