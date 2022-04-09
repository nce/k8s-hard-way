# https://kubernetes.io/docs/tasks/administer-cluster/certificates/#openssl
resource "tls_private_key" "etcd_ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "etcd_ca" {
  private_key_pem = tls_private_key.etcd_ca.private_key_pem

  subject {
    common_name  = "etcd"
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

