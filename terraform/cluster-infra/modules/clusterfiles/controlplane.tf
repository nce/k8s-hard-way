locals {
  files_controlplane_configs = merge(
    {
      for filename in fileset("${path.module}/files/controlplane/", "**/*") : "/${filename}" => {
        mode  = "0644"
        user  = "root"
        group = "root"

        content = templatefile("${path.module}/files/controlplane/${filename}", {
          k8s_cluster_name = var.k8s_cluster_name

          etcd_version          = var.etcd_version
          etcd_peer_name        = "etcd0"
          etcd_discovery_domain = var.etcd_discovery_domain

          # kube-apiserver
          controller_count        = 1
          kubernetes_service_cidr = var.k8s_service_cidr
          k8s_api_extern          = var.k8s_api_extern
          kubernetes_version      = var.k8s_version

          cluster_dns = var.k8s_cluster_dns

        })
      }
    },
    # https://kubernetes.io/docs/setup/best-practices/certificates/#certificate-paths
    {
      "/etc/kubernetes/pki/etcd/ca.key" = {
        user    = "etcd"
        group   = "etcd"
        mode    = "0600"
        content = var.etcd_pki_ca_crt
      }
      "/etc/kubernetes/pki/etcd/ca.crt" = {
        user    = "etcd"
        group   = "etcd"
        mode    = "0644"
        content = var.etcd_pki_ca_crt
      }
      "/etc/kubernetes/pki/apiserver-etcd-client.key" = {
        user    = "root"
        group   = "root"
        mode    = "0600"
        content = var.k8s_pki_apiserver_etcd_client_key
      }
      "/etc/kubernetes/pki/apiserver-etcd-client.crt" = {
        user    = "root"
        group   = "root"
        mode    = "0644"
        content = var.k8s_pki_apiserver_etcd_client_crt
      }
      "/etc/kubernetes/pki/ca.crt" = {
        user    = "root"
        group   = "root"
        mode    = "0644"
        content = var.k8s_pki_ca_crt
      }
      "/etc/kubernetes/pki/ca.key" = {
        user    = "root"
        group   = "root"
        mode    = "0600"
        content = var.k8s_pki_ca_key
      }
      "/etc/kubernetes/pki/apiserver.crt" = {
        user    = "root"
        group   = "root"
        mode    = "0644"
        content = var.k8s_pki_apiserver_crt
      }
      "/etc/kubernetes/pki/apiserver.key" = {
        user    = "root"
        group   = "root"
        mode    = "0600"
        content = var.k8s_pki_apiserver_key
      }
      "/etc/kubernetes/pki/sa.pub" = {
        user    = "root"
        group   = "root"
        mode    = "0644"
        content = var.k8s_pki_serviceaccount_pub
      }
      "/etc/kubernetes/pki/sa.key" = {
        user    = "root"
        group   = "root"
        mode    = "0600"
        content = var.k8s_pki_serviceaccount_key
      }
      "/etc/kubernetes/pki/etcd/server.key" = {
        user    = "etcd"
        group   = "etcd"
        mode    = "0600"
        content = var.etcd_pki_server_key
      }
      "/etc/kubernetes/pki/etcd/server.crt" = {
        user    = "etcd"
        group   = "etcd"
        mode    = "0644"
        content = var.etcd_pki_server_crt
      }
      "/etc/kubernetes/pki/etcd/peer.key" = {
        user    = "etcd"
        group   = "etcd"
        mode    = "0600"
        content = var.etcd_pki_peer_key
      }
      "/etc/kubernetes/pki/etcd/peer.crt" = {
        user    = "etcd"
        group   = "etcd"
        mode    = "0644"
        content = var.etcd_pki_peer_crt
      }
      "/etc/kubernetes/pki/apiserver-kubelet-client.key" = {
        user    = "root"
        group   = "root"
        mode    = "0600"
        content = var.k8s_pki_apiserver_kubelet_client_key
      }
      "/etc/kubernetes/pki/apiserver-kubelet-client.crt" = {
        user    = "root"
        group   = "root"
        mode    = "0644"
        content = var.k8s_pki_apiserver_kubelet_client_crt
      }
      "/var/lib/kubelet/bootstrap-kubeconfig" = {
        user    = "root"
        group   = "root"
        mode    = "0600"
        content = module.bootstrap_kubeconfig.kubeconfig
      }
  })
}

module "bootstrap_kubeconfig" {
  source = "../kubeconfig"

  k8s_cluster_name = var.k8s_cluster_name
  k8s_api          = "127.0.0.1"
  k8s_username     = "kubelet-bootstrap"
  k8s_pki_ca_crt   = var.k8s_pki_ca_crt
  k8s_token        = "07401b.f395accd246ae52d"

}
