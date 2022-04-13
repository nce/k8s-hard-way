resource "tls_private_key" "k8s_front_proxy_ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "k8s_front_proxy_ca" {
  private_key_pem = tls_private_key.k8s_front_proxy_ca.private_key_pem

  subject {
    common_name  = "kubernetes-front-proxy-ca"
    organization = "nce ACME"
  }

  is_ca_certificate = true
  # one year
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "tls_private_key" "k8s_front_proxy" {
  algorithm = tls_private_key.k8s_ca.algorithm
  rsa_bits  = tls_private_key.k8s_ca.rsa_bits
}

resource "tls_cert_request" "k8s_front_proxy" {
  private_key_pem = tls_private_key.k8s_front_proxy.private_key_pem

  subject {
    common_name = "front-proxy-client"
  }
}

resource "tls_locally_signed_cert" "k8s_front_proxy" {
  cert_request_pem   = tls_cert_request.k8s_front_proxy.cert_request_pem
  ca_private_key_pem = tls_private_key.k8s_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.k8s_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}
