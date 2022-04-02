resource "random_id" "etcd_encryption_key" {
  byte_length = 32
}

resource "local_file" "k8s_controller_cri" {
  content = templatefile("cri/crio.sh.tftpl", {
    crio_version = var.crio_version
  })

  filename = "./crio/generated/crio.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_controller_baseos" {
  count = var.controller_instances

  depends_on = [
    aws_instance.controller,
    null_resource.k8s_bastion_baseos
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

resource "local_file" "k8s_controller_proxy" {
  count = var.controller_instances

  content = templatefile("kube-proxy/kube-proxy.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_private_ip = aws_instance.bastion.private_ip
  })

  filename = "./kube-proxy/generated/controller${count.index}-kube-proxy.sh"

  depends_on = [
    aws_instance.controller
  ]
}

resource "null_resource" "k8s_instance_controller_proxy" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_instance_controller,
    null_resource.k8s_ca,
    null_resource.k8s_proxy_controller,
    null_resource.k8s_admin,
    local_file.k8s_controller_proxy,
    null_resource.k8s_bastion_baseos,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./kube-proxy/generated/controller${count.index}-kube-proxy.sh"
    destination = "kube-proxy.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x kube-proxy.sh",
      "sudo ./kube-proxy.sh"
    ]
  }
}

resource "null_resource" "k8s_instance_controller_cri" {
  count = var.controller_instances

  depends_on = [
    local_file.k8s_controller_cri,
    null_resource.k8s_controller_baseos,
    null_resource.k8s_bastion_baseos
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
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

resource "local_file" "k8s_controller_kubelet" {
  count = var.controller_instances

  content = templatefile("kubelet/kubelet.sh.tftpl", {
    k8s_version        = var.k8s_version
    cluster_private_ip = aws_instance.bastion.private_ip
    pod_cidr           = "10.200.${count.index}.0/24"
  })

  filename = "./kubelet/generated/controller${count.index}-kubelet.sh"

  depends_on = [
    aws_instance.controller,
    null_resource.k8s_controller_baseos,
  ]
}

resource "null_resource" "k8s_instance_controller" {
  count = var.controller_instances

  depends_on = [
    null_resource.k8s_ca,
    null_resource.k8s_kubelet_controller,
    null_resource.k8s_proxy,
    null_resource.k8s_admin,
    null_resource.k8s_bastion_baseos,
    null_resource.k8s_instance_controller_cri,
    local_file.k8s_controller_kubelet,
  ]

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         = aws_instance.controller.*.private_ip[count.index]
    bastion_host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./kubelet/generated/controller${count.index}-kubelet.sh"
    destination = "kubelet.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x kubelet.sh",
      "sudo ./kubelet.sh"
    ]
  }
}


resource "local_file" "k8s_apiserver" {
  count = var.controller_instances

  content = templatefile("apiserver/apiserver.sh.tftpl", {
    k8s_version          = var.k8s_version
    controller_instances = var.controller_instances
    etcd_server          = "https://${join(":2379,https://", aws_instance.controller.*.private_ip)}:2379"
    cluster_service_cidr = var.cluster_service_cidr
    encryption_key       = random_id.etcd_encryption_key.b64_std
    public_cluster_url   = aws_route53_record.k8s_api.name
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
    null_resource.k8s_controller_baseos,
    null_resource.k8s_bastion_baseos,
    local_file.k8s_apiserver,
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
    cluster_public_dns = aws_route53_record.k8s_api.name
    dex_login_url      = var.dex_login_url
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
    null_resource.k8s_bastion_baseos,
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
    null_resource.k8s_bastion_baseos,
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
    k8s_version          = var.k8s_version
    cluster_cidr         = var.cluster_pod_cidr
    cluster_service_cidr = var.cluster_service_cidr
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
    null_resource.k8s_bastion_baseos,
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

resource "null_resource" "k8s_admin_kubeconfig_local" {

  depends_on = [
    null_resource.k8s_admin_kubeconfig
  ]

  provisioner "local-exec" {
    command = "scp -o ProxyCommand=\"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${aws_instance.bastion.public_ip} -W %h:%p\" -o \"StrictHostKeyChecking=no\" -o \"UserKnownHostsFile=/dev/null\" ec2-user@${aws_instance.controller[0].private_ip}:admin.kubeconfig ."
  }
}

resource "time_sleep" "wait_for_k8s_api" {
  create_duration = "20s"

  depends_on = [
    null_resource.k8s_admin_kubeconfig_local,
    null_resource.k8s_instance_controller_apiserver,
    aws_security_group.worker,
    aws_security_group.controller,
    aws_security_group.bastion,
    #aws_security_group_rule.k8sapi,
    #aws_security_group_rule.ssh_to_controller,
    #aws_security_group_rule.etcd_to_controller,
    #aws_security_group_rule.scheduler_from_controller,
    ##aws_security_group_rule.controllermanager_from_controller,
    #aws_security_group_rule.proxy_from_controller,
    #aws_security_group_rule.kubelet_from_controller,
  ]
}

resource "kubectl_manifest" "cr_kubelet" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
YAML
}

resource "kubectl_manifest" "crb_kubelet" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
YAML
}

resource "kubectl_manifest" "awscredentials_secret" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
data:
  keyid: ${base64encode(aws_iam_access_key.ingress_lb.id)}
  keysecret: ${base64encode(aws_iam_access_key.ingress_lb.secret)}
kind: Secret
metadata:
  annotations:
  name: awscredentials
  namespace: kube-system
type: Opaque
YAML
}

data "aws_ssm_parameter" "sealed_secret_cert" {
  name = "/ugo-kubernetes-the-hard-way/sealedsecrets/sealedsecrets.crt"
}
data "aws_ssm_parameter" "sealed_secret_key" {
  name = "/ugo-kubernetes-the-hard-way/sealedsecrets/sealedsecrets.key"
}

resource "kubectl_manifest" "sealed_secret_namespace" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: infra-sealed-secret
YAML
}

resource "kubectl_manifest" "sealed_secret_master" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: custom-master-key
  namespace: infra-sealed-secret
  labels:
    sealedsecrets.bitnami.com/sealed-secrets-key: active
type: kubernetes.io/tls
data:
  tls.crt: |
    ${indent(4, base64encode(data.aws_ssm_parameter.sealed_secret_cert.value))}
  tls.key: |
    ${indent(4, base64encode(data.aws_ssm_parameter.sealed_secret_key.value))}
YAML
}

resource "kubectl_manifest" "dex_namespace" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: infra-dex
YAML
}

resource "kubectl_manifest" "argocd_namespace" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: infra-argocd
YAML
}

resource "kubectl_manifest" "dex_github_connector" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = yamlencode(jsondecode(file("sealedsecrets/secrets/dex-github-connector.json")))
}


resource "random_password" "dex_argocd_client" {
  length  = 16
  special = true
}

resource "kubectl_manifest" "dex_argocd_client" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-argocd-client
  namespace: infra-argocd
  labels:
    app.kubernetes.io/part-of: argocd
type: Opaque
data:
  client-id: ${base64encode("argo")}
  client-secret: ${base64encode(random_password.dex_argocd_client.result)}
YAML
}

resource "kubectl_manifest" "dex_argocd_dex_client" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-argocd-client
  namespace: infra-dex
type: Opaque
data:
  client-id: ${base64encode("argo")}
  client-secret: ${base64encode(random_password.dex_argocd_client.result)}
YAML
}

resource "kubectl_manifest" "clusterrolebinding_oidc" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-oidc-group
subjects:
- kind: Group
  name: oidc:nce-acme:admin # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
YAML
}

data "kubectl_file_documents" "calico" {
  content = file("calico/calico.yaml")
}

resource "kubectl_manifest" "calico" {
  for_each  = data.kubectl_file_documents.calico.manifests
  yaml_body = each.value

  depends_on = [
    time_sleep.wait_for_k8s_api,
    null_resource.k8s_taint_label_controller
  ]

}

resource "null_resource" "k8s_taint_label_controller" {
  count = var.controller_instances

  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig admin.kubeconfig taint --overwrite=true nodes ${aws_instance.controller.*.private_dns[count.index]} node-role.kubernetes.io/master=:NoSchedule && kubectl --kubeconfig admin.kubeconfig label --overwrite=true nodes ${aws_instance.controller.*.private_dns[count.index]} node-role.kubernetes.io/master=\"\""
  }

}
