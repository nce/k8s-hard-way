output "ca_key" {
  value = tls_private_key.k8s_ca.private_key_pem
}

output "ca_crt" {
  value = tls_self_signed_cert.k8s_ca.cert_pem
}
