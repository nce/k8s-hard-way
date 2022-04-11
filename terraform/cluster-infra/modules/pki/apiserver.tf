resource "tls_private_key" "k8s_apiserver" {
  algorithm = tls_private_key.k8s_ca.algorithm
  rsa_bits  = tls_private_key.k8s_ca.rsa_bits
}

resource "tls_cert_request" "k8s_apiserver" {
  private_key_pem = tls_private_key.k8s_apiserver.private_key_pem

  subject {
    common_name = "kube-apiserver"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local",
    var.k8s_api_extern
  ]

  ip_addresses = [
    "127.0.0.1",
    var.k8s_service_ip
  ]
}

resource "tls_locally_signed_cert" "k8s_apiserver" {
  cert_request_pem   = tls_cert_request.k8s_apiserver.cert_request_pem
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
