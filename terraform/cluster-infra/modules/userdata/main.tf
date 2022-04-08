locals {
  files_rendered = {
    for filename in fileset("${path.module}/files/", "**/*") : "/${filename}" => {
      mode  = "0644"
      user  = "root"
      group = "root"

      content = templatefile("${path.module}/files/${filename}", {})
    }
  }
}
#
#  snippets = [for filename in fileset("${path.module}/resources/snippets/", "*.yaml") : templatefile("${path.module}/resources/snippets/${filename}", {
#    kubernetes_version = var.kubernetes_version
#  })]
#}
#
module "ignition" {
  source = "../../modules/ignition"

  k8s_cluster_name = var.k8s_cluster_name
  files            = merge(local.files_rendered, var.files)
  #snippets = local.snippets
}

