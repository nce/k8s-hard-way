locals {
  controlplane_filelist = fileset("${path.module}/files/controlplane/", "**/*")

  # files uploaded to s3
  files_templates_rendered = { for filename in local.controlplane_filelist : "/${filename}" => templatefile("${path.module}/files/controlplane/${filename}", {

    etcd_version          = var.k8s_etcd_version
    etcd_peer_name        = "hello1"
    etcd_discovery_domain = "foobar"

    cluster_dns = var.k8s_cluster_dns
  }) }

  # ignition files to download from s3
  files_templates = [for filename in local.controlplane_filelist : templatefile("${path.module}/files/ignition/templates/remote_file.yaml", {
    path   = "/controlplane/${filename}"
    bucket = var.s3_ignition_bucket
    mode   = "0644"
    user   = "root"
    group  = "root"
  })]
  pki = {
    "/etc/kubernetes/pki/ca.crt" = {
      content = var.k8s_pki_ca_cert
      mode    = "0644"
      user    = "root"
      group   = "root"
    }
    "/var/lib/kubelet/bootstrap-kubeconfig" = {
      content = yamlencode(module.kubeconfig_kubelet_bootstrap.kubeconfig_content)
      mode    = "0600"
      user    = "root"
      group   = "root"
    }
  }

  pki_templates = [for filename, attr in local.pki : templatefile("${path.module}/files/ignition/templates/remote_file.yaml", {
    path   = "/controlplane/${filename}"
    bucket = var.s3_ignition_bucket
    mode   = attr.mode
    user   = attr.user
    group  = attr.group
  })]

  pki_rendered = { for filename, file in local.pki : filename => file.content }

}

data "ct_config" "controlplane" {
  strict = true

  content = templatefile("${path.module}/files/ignition/controlplane.yaml", {

    kubernetes_version = var.k8s_kubernetes_version
    kubectl_sha512     = var.k8s_kubectl_sha512
    kubelet_sha512     = var.k8s_kubelet_sha512

  })

  snippets = concat(
    local.files_templates,
    local.pki_templates
  )
}


# s3 upload of ignition file
resource "aws_s3_object" "controlplane" {

  bucket  = var.s3_ignition_bucket
  key     = "/controlplane-${sha512(data.ct_config.controlplane.rendered)}.ignition"
  content = data.ct_config.controlplane.rendered
}

# s3 upload of templates/files
resource "aws_s3_object" "controlplane_templates" {
  for_each = merge(local.files_templates_rendered, local.pki_rendered)

  bucket  = var.s3_ignition_bucket
  key     = "/controlplane/${each.key}"
  content = each.value

  #server_side_encryption = "AES256"

  #etag        = md5(each.value)
  #source_hash = md5(each.value)
}

module "kubeconfig_kubelet_bootstrap" {
  source  = "redeux/kubeconfig/kubernetes"
  version = "0.0.2"

  current_context = "bootstrap"
  clusters = [{
    name : "bootstrap",
    server : "https://127.0.0.1:6443",
    certificate_authority_data : base64encode(var.k8s_pki_ca_cert)
  }]
  contexts = [{
    name : "bootstrap",
    cluster_name : "bootstrap",
    user : "kubelet-bootstrap"
  }]
  users = [{
    name : "kubelet-boostrap",
    token : "07401b.f395accd246ae52d"
  }]
}
