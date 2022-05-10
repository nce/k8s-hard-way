locals {
  kubeconfig = templatefile("${path.module}/files/kubeconfig.tpl", {
    k8s_cluster_name   = var.k8s_cluster_name
    k8s_api            = var.k8s_api
    k8s_username       = var.k8s_username
    k8s_pki_ca_crt     = var.k8s_pki_ca_crt
    k8s_pki_client_crt = var.k8s_pki_client_crt
    k8s_pki_client_key = var.k8s_pki_client_key
    k8s_token          = var.k8s_token
  })
}
