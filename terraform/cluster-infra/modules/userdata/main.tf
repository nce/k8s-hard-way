locals {
  files_rendered = {
    for filename in fileset("${path.module}/files/", "**/*") : "/${filename}" => {
      mode  = "0644"
      user  = "root"
      group = "root"

      content = templatefile("${path.module}/files/${filename}", {})
    }
  }

  snippets = [for filename in fileset("${path.module}/snippets/", "*.yaml") : templatefile("${path.module}/snippets/${filename}", {
    k8s_kubernetes_version = var.k8s_kubernetes_version
    k8s_kubelet_sha512     = var.k8s_kubelet_sha512
    k8s_kubectl_sha512     = var.k8s_kubectl_sha512

  })]
}

module "ignition" {
  source = "../../modules/ignition"

  k8s_cluster_name = var.k8s_cluster_name
  files            = merge(local.files_rendered, var.files)
  snippets         = local.snippets
}

