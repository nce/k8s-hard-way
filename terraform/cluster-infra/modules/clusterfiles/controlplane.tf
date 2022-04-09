locals {
  files_controlplane_configs = merge(
    {
      for filename in fileset("${path.module}/files/controlplane/", "**/*") : "/${filename}" => {
        mode  = "0644"
        user  = "root"
        group = "root"

        content = templatefile("${path.module}/files/controlplane/${filename}", {
          k8s_cluster_name = var.k8s_cluster_name

          etcd_version          = "123"
          etcd_peer_name        = "hello1"
          etcd_discovery_domain = "foobar"

          # kube-apiserver
          controller_count        = 1
          kubernetes_service_cidr = "10.31.0.1/24"
          k8s_api_extern          = "foobar"
          kubernetes_version      = "1.23.0"

          cluster_dns = "foo"

        })
      }
    },
    {
      "/etc/kubernetes/pki/ca.crt" = {
        user    = "root"
        group   = "root"
        mode    = "0644"
        content = var.k8s_ca_crt
      }
  })
}
