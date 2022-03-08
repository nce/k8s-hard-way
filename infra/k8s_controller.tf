resource "random_id" "etcd_encryption_key" {
  byte_length = 32
}

resource "null_resource" "k8s_controller_baseos" {
  count = var.controller_instances

  depends_on = [
    aws_instance.controller
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
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

resource "local_file" "k8s_apiserver" {
  count = var.controller_instances

  content = templatefile("apiserver/apiserver.sh.tftpl", {
    k8s_version          = var.k8s_version
    controller_instances = var.controller_instances
    etcd_server          = "https://${join(":2379,https://", aws_instance.controller.*.private_ip)}:2379"
    cluster_private_ip   = aws_instance.bastion.private_ip
    cluster_service_ip   = var.cluster_service_ip
    encryption_key       = random_id.etcd_encryption_key.b64_std
  })

  filename = "./apiserver/generated/controller${count.index}.apiserver.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_instance_controller_apiserver" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_ca,
    null_resource.k8s_apiserver,
    null_resource.k8s_service_account,
    local_file.k8s_apiserver,
    null_resource.k8s_controller_baseos
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./apiserver/generated/controller${count.index}.apiserver.sh"
    destination = "apiserver.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x apiserver.sh",
      "sudo ./apiserver.sh"
    ]
  }
}

resource "local_file" "k8s_admin_kubeconfig" {
  content = templatefile("apiserver/adminkubeconfig.sh.tftpl", {
    cluster_public_ip = aws_instance.bastion.public_ip
  })

  filename = "./apiserver/generated/adminkubeconfig.sh"

  depends_on = [
    null_resource.k8s_instance_controller_apiserver
  ]
}

resource "null_resource" "k8s_admin_kubeconfig" {

  depends_on = [
    null_resource.k8s_controller_baseos,
    null_resource.k8s_admin,
    null_resource.k8s_ca,
    local_file.k8s_admin_kubeconfig,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller[0].private_ip
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./apiserver/generated/adminkubeconfig.sh"
    destination = "adminkubeconfig.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x adminkubeconfig.sh",
      "sudo ./adminkubeconfig.sh"
    ]
  }
}

resource "local_file" "k8s_kube_scheduler" {
  count = var.controller_instances

  content = templatefile("kube-scheduler/kube-scheduler.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_private_ip = aws_instance.bastion.private_ip
  })

  filename = "./kube-scheduler/generated/controller${count.index}.kube-scheduler.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_instance_controller_kube_scheduler" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_ca,
    null_resource.k8s_scheduler,
    local_file.k8s_kube_scheduler,
    null_resource.k8s_instance_controller_apiserver
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./kube-scheduler/generated/controller${count.index}.kube-scheduler.sh"
    destination = "kube-scheduler.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x kube-scheduler.sh",
      "sudo ./kube-scheduler.sh"
    ]
  }
}

resource "local_file" "k8s_kube_controller_manager" {
  count = var.controller_instances

  content = templatefile("kube-controller-manager/kube-controller-manager.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_cidr       = var.cluster_pod_cidr
    cluster_service_ip = var.cluster_service_ip
  })

  filename = "./kube-controller-manager/generated/controller${count.index}.kube-controller-manager.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_instance_kube_controller_manager" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_ca,
    null_resource.k8s_controller_manager,
    null_resource.k8s_service_account,
    local_file.k8s_kube_controller_manager,
    null_resource.k8s_instance_controller_kube_scheduler
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./kube-controller-manager/generated/controller${count.index}.kube-controller-manager.sh"
    destination = "kube-controller-manager.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x kube-controller-manager.sh",
      "sudo ./kube-controller-manager.sh"
    ]
  }
}
