resource "local_file" "k8s_worker_cri" {
  content = templatefile("cri/crio.sh.tftpl", {
    crio_version = var.crio_version
  })

  filename = "./crio/generated/crio.sh"

  depends_on = [aws_instance.worker]
}

resource "null_resource" "k8s_worker_baseos" {
  count = var.worker_instances

  depends_on = [
    aws_instance.worker
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip

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

resource "null_resource" "k8s_instance_worker_cri" {
  count = var.worker_instances

  depends_on = [
    local_file.k8s_worker_cri,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./crio/generated/crio.sh"
    destination = "crio.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x crio.sh",
      "sudo ./crio.sh"
    ]
  }
}

resource "local_file" "k8s_worker_kubelet" {
  count = var.worker_instances

  content = templatefile("kubelet/kubelet.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_private_ip = aws_instance.bastion.private_ip
    pod_cidr           = "10.200.${count.index}.0/24"
  })

  filename = "./kubelet/generated/worker${count.index}-kubelet.sh"

  depends_on = [
    aws_instance.worker,
    null_resource.k8s_instance_worker_cri,
    null_resource.k8s_controller_baseos
  ]
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

resource "local_file" "k8s_worker_proxy" {
  count = var.worker_instances

  content = templatefile("kube-proxy/kube-proxy.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_private_ip = aws_instance.bastion.private_ip
  })

  filename = "./kube-proxy/generated/worker${count.index}-kube-proxy.sh"

  depends_on = [
    aws_instance.worker
  ]
}

resource "null_resource" "k8s_instance_worker_proxy" {
  count = var.worker_instances

  depends_on = [
    null_resource.k8s_instance_worker,
    null_resource.k8s_ca_worker,
    null_resource.k8s_proxy,
    null_resource.k8s_admin,
    local_file.k8s_worker_proxy,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./kube-proxy/generated/worker${count.index}-kube-proxy.sh"
    destination = "kube-proxy.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x kube-proxy.sh",
      "sudo ./kube-proxy.sh"
    ]
  }
}



