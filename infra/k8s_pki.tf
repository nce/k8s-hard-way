# https://kubernetes.io/docs/tasks/administer-cluster/certificates/#openssl
resource "tls_private_key" "k8s_ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "k8s_ca" {
  key_algorithm   = tls_private_key.k8s_ca.algorithm
  private_key_pem = tls_private_key.k8s_ca.private_key_pem

  subject {
    common_name  = "Kubernetes"
    organization = "nce ACME"
  }

  is_ca_certificate = true
  # one year
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "k8s_ca_key" {
  content  = tls_private_key.k8s_ca.private_key_pem
  filename = "./pki/generated/ca-key.pem"
}
resource "local_file" "k8s_ca_cert" {
  content  = tls_self_signed_cert.k8s_ca.cert_pem
  filename = "./pki/generated/ca-cert.pem"
}
resource "null_resource" "k8s_ca_worker" {
  count = var.worker_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/ca-cert.pem"
    destination = "ca-cert.pem"
  }
}
resource "null_resource" "k8s_ca" {
  count = var.controller_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/ca-key.pem"
    destination = "ca-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/ca-cert.pem"
    destination = "ca-cert.pem"
  }
}
# ------------------------
# -- [ apiserver cert ] --
resource "tls_private_key" "k8s_apiserver" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_apiserver" {
  key_algorithm   = tls_private_key.k8s_apiserver.algorithm
  private_key_pem = tls_private_key.k8s_apiserver.private_key_pem

  subject {
    common_name         = "Kubernetes"
    organization        = "nce ACME"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ]

  ip_addresses = concat([
    "127.0.0.1",
    # cluster service
    var.cluster_service_ip,
    # public api
    aws_instance.bastion.public_ip
    ],
    # controller ips
    aws_instance.controller.*.private_ip
  )
}

resource "tls_locally_signed_cert" "k8s_apiserver" {
  cert_request_pem   = tls_cert_request.k8s_apiserver.cert_request_pem
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "k8s_apiserver_key" {
  content  = tls_private_key.k8s_apiserver.private_key_pem
  filename = "./pki/generated/apiserver-key.pem"
}
resource "local_file" "k8s_apiserver_cert" {
  content  = tls_locally_signed_cert.k8s_apiserver.cert_pem
  filename = "./pki/generated/apiserver-cert.pem"
}

resource "null_resource" "k8s_apiserver" {
  count = var.controller_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/apiserver-key.pem"
    destination = "apiserver-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/apiserver-cert.pem"
    destination = "apiserver-cert.pem"
  }
}
# -- [ apiserver cert ] --
# ------------------------

# --------------------
# -- [ admin cert ] --
resource "tls_private_key" "k8s_admin" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_admin" {
  key_algorithm   = tls_private_key.k8s_admin.algorithm
  private_key_pem = tls_private_key.k8s_admin.private_key_pem

  subject {
    common_name         = "admin"
    organization        = "system:masters"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }
}

resource "tls_locally_signed_cert" "k8s_admin" {
  cert_request_pem   = tls_cert_request.k8s_admin.cert_request_pem
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}
resource "local_file" "k8s_admin_key" {
  content  = tls_private_key.k8s_admin.private_key_pem
  filename = "./pki/generated/admin-key.pem"
}
resource "local_file" "k8s_admin_cert" {
  content  = tls_locally_signed_cert.k8s_admin.cert_pem
  filename = "./pki/generated/admin-cert.pem"
}

resource "null_resource" "k8s_admin" {
  count = var.controller_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/admin-key.pem"
    destination = "admin-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/admin-cert.pem"
    destination = "admin-cert.pem"
  }
}
# -- [ admin cert ] --
# --------------------

# ----------------------
# -- [ kubelet cert ] --
resource "tls_private_key" "k8s_kubelet" {
  count = var.worker_instances

  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_kubelet" {
  count = var.worker_instances

  key_algorithm   = tls_private_key.k8s_kubelet.*.algorithm[count.index]
  private_key_pem = tls_private_key.k8s_kubelet.*.private_key_pem[count.index]

  ip_addresses = [
    aws_instance.worker.*.private_ip[count.index]
  ]

  subject {
    common_name         = "system:node:${aws_instance.worker.*.private_dns[count.index]}"
    organization        = "system:nodes"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }
}

resource "tls_locally_signed_cert" "k8s_kubelet" {
  count = var.worker_instances

  cert_request_pem   = tls_cert_request.k8s_kubelet.*.cert_request_pem[count.index]
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}
resource "local_file" "k8s_kubelet_key" {
  count    = var.worker_instances
  content  = tls_private_key.k8s_kubelet.*.private_key_pem[count.index]
  filename = "./pki/generated/worker${count.index}-kubelet-key.pem"
}
resource "local_file" "k8s_kubelet_cert" {
  count    = var.worker_instances
  content  = tls_locally_signed_cert.k8s_kubelet.*.cert_pem[count.index]
  filename = "./pki/generated/worker${count.index}-kubelet-cert.pem"
}

resource "null_resource" "k8s_kubelet" {
  count = var.worker_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/worker${count.index}-kubelet-key.pem"
    destination = "kubelet-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/worker${count.index}-kubelet-cert.pem"
    destination = "kubelet-cert.pem"
  }
}
# -- [ kubelet cert ] --
# ----------------------


# ---------------------------------
# -- [ controller_manager cert ] --
resource "tls_private_key" "k8s_controller_manager" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_controller_manager" {
  key_algorithm   = tls_private_key.k8s_controller_manager.algorithm
  private_key_pem = tls_private_key.k8s_controller_manager.private_key_pem

  subject {
    common_name         = "system:kube-controller-manager"
    organization        = "system:kube-controller-manager"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }
}

resource "tls_locally_signed_cert" "k8s_controller_manager" {
  cert_request_pem   = tls_cert_request.k8s_controller_manager.cert_request_pem
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}
resource "local_file" "k8s_controller_manager_key" {
  content  = tls_private_key.k8s_controller_manager.private_key_pem
  filename = "./pki/generated/controllermanager-key.pem"
}
resource "local_file" "k8s_controller_manager_cert" {
  content  = tls_locally_signed_cert.k8s_controller_manager.cert_pem
  filename = "./pki/generated/controllermanager-cert.pem"
}

resource "null_resource" "k8s_controller_manager" {
  count = var.controller_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/controllermanager-key.pem"
    destination = "controllermanager-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/controllermanager-cert.pem"
    destination = "controllermanager-cert.pem"
  }
}
# -- [ controller_manager cert ] --
# ---------------------------------

# -- [ proxy cert ] --
resource "tls_private_key" "k8s_proxy" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_proxy" {
  key_algorithm   = tls_private_key.k8s_proxy.algorithm
  private_key_pem = tls_private_key.k8s_proxy.private_key_pem

  subject {
    common_name         = "system:kube-proxy"
    organization        = "system:node-proxier"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }
}

resource "tls_locally_signed_cert" "k8s_proxy" {
  cert_request_pem   = tls_cert_request.k8s_proxy.cert_request_pem
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}
resource "local_file" "k8s_proxy_key" {
  count    = var.worker_instances
  content  = tls_private_key.k8s_proxy.private_key_pem
  filename = "./pki/generated/worker${count.index}-proxy-key.pem"
}
resource "local_file" "k8s_proxy_cert" {
  count    = var.worker_instances
  content  = tls_locally_signed_cert.k8s_proxy.cert_pem
  filename = "./pki/generated/worker${count.index}-proxy-cert.pem"
}

resource "null_resource" "k8s_proxy" {
  count = var.worker_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.worker.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/worker${count.index}-proxy-key.pem"
    destination = "proxy-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/worker${count.index}-proxy-cert.pem"
    destination = "proxy-cert.pem"
  }
}
# -- [ proxy cert ] --
# --------------------

# ------------------------
# -- [ scheduler cert ] --
resource "tls_private_key" "k8s_scheduler" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_scheduler" {
  key_algorithm   = tls_private_key.k8s_scheduler.algorithm
  private_key_pem = tls_private_key.k8s_scheduler.private_key_pem

  subject {
    common_name         = "system:kube-scheduler"
    organization        = "system:kube-scheduler"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }
}

resource "tls_locally_signed_cert" "k8s_scheduler" {
  cert_request_pem   = tls_cert_request.k8s_scheduler.cert_request_pem
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "k8s_scheduler_key" {
  content  = tls_private_key.k8s_scheduler.private_key_pem
  filename = "./pki/generated/scheduler-key.pem"
}
resource "local_file" "k8s_scheduler_cert" {
  content  = tls_locally_signed_cert.k8s_scheduler.cert_pem
  filename = "./pki/generated/scheduler-cert.pem"
}

resource "null_resource" "k8s_scheduler" {
  count = var.controller_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/scheduler-key.pem"
    destination = "scheduler-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/scheduler-cert.pem"
    destination = "scheduler-cert.pem"
  }
}
# -- [ scheduler cert ] --
# ------------------------

# ------------------------------
# -- [ service_account cert ] --
resource "tls_private_key" "k8s_service_account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "tls_cert_request" "k8s_service_account" {
  key_algorithm   = tls_private_key.k8s_service_account.algorithm
  private_key_pem = tls_private_key.k8s_service_account.private_key_pem

  subject {
    common_name         = "service-accounts"
    organization        = "Kubernetes"
    country             = "DE"
    locality            = "Bavaria"
    organizational_unit = "K8s the hard way"
  }
}

resource "tls_locally_signed_cert" "k8s_service_account" {
  cert_request_pem   = tls_cert_request.k8s_service_account.cert_request_pem
  ca_key_algorithm   = tls_private_key.k8s_ca.algorithm
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "k8s_service_account_key" {
  content  = tls_private_key.k8s_service_account.private_key_pem
  filename = "./pki/generated/serviceaccount-key.pem"
}
resource "local_file" "k8s_service_account_cert" {
  content  = tls_locally_signed_cert.k8s_service_account.cert_pem
  filename = "./pki/generated/serviceaccount-cert.pem"
}

resource "null_resource" "k8s_service_account" {
  count = var.controller_instances

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./pki/generated/serviceaccount-key.pem"
    destination = "serviceaccount-key.pem"
  }
  provisioner "file" {
    source      = "./pki/generated/serviceaccount-cert.pem"
    destination = "serviceaccount-cert.pem"
  }
}
# -- [ service_account cert ] --
# ------------------------------
