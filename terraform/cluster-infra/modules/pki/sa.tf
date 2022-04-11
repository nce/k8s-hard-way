resource "tls_private_key" "k8s_serviceaccount" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
