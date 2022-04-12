resource "tls_private_key" "k8s_apiserver_etcd_client" {
  algorithm = tls_private_key.etcd_ca.algorithm
  rsa_bits  = tls_private_key.etcd_ca.rsa_bits
}

resource "tls_cert_request" "k8s_apiserver_etcd_client" {
  private_key_pem = tls_private_key.k8s_apiserver_etcd_client.private_key_pem

  subject {
    common_name  = "kube-apiserver-etcd-client"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "k8s_apiserver_etcd_client" {
  cert_request_pem   = tls_cert_request.k8s_apiserver_etcd_client.cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.etcd_ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}
