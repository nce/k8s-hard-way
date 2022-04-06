module "ignition" {
  source = "./modules/ignition"

  k8s_kubernetes_version = var.kubernetes_version
  k8s_kubectl_sha512     = var.kubectl_sha512
  k8s_kubelet_sha512     = var.kubelet_sha512

  k8s_etcd_version = var.etcd_version

  k8s_cluster_dns = var.k8s_cluster_dns

  s3_ignition_bucket = aws_s3_bucket.ignition.id

  k8s_pki_ca_cert = module.pki.ca_crt
  k8s_pki_ca_key  = module.pki.ca_key

  depends_on = [
    aws_s3_bucket.ignition
  ]

}
