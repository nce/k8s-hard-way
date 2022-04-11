resource "tls_private_key" "k8s_controller_manager" {
  algorithm = tls_private_key.k8s_ca.algorithm
  rsa_bits  = tls_private_key.k8s_ca.rsa_bits
}

resource "tls_cert_request" "k8s_controller_manager" {
  private_key_pem = tls_private_key.k8s_controller_manager.private_key_pem

  subject {
    common_name = "system:kube-controller-manager"
  }
}

resource "tls_locally_signed_cert" "k8s_controller_manager" {
  cert_request_pem   = tls_cert_request.k8s_controller_manager.cert_request_pem
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}
