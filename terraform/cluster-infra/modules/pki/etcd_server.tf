resource "tls_private_key" "k8s_etcd_server" {
  count     = var.k8s_controlplane_count
  algorithm = tls_private_key.etcd_ca.algorithm
  rsa_bits  = tls_private_key.etcd_ca.rsa_bits
}

resource "tls_cert_request" "k8s_etcd_server" {
  count           = var.k8s_controlplane_count
  private_key_pem = tls_private_key.k8s_etcd_server[count.index].private_key_pem

  subject {
    common_name = "kube-etcd"
  }

  ip_addresses = [
    "127.0.0.1"
  ]

  dns_names = [
    "localhost",
    "etcd${count.index}.${var.etcd_discovery_domain}"
  ]
}

resource "tls_locally_signed_cert" "k8s_etcd_server" {
  count              = var.k8s_controlplane_count
  cert_request_pem   = tls_cert_request.k8s_etcd_server[count.index].cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.etcd_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth"
  ]
}
