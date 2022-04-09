output "ca_key" {
  value = tls_private_key.k8s_ca.private_key_pem
}

output "ca_crt" {
  value = tls_self_signed_cert.k8s_ca.cert_pem
}

output "etcd_ca_key" {
  value = tls_private_key.etcd_ca.private_key_pem
}

output "etcd_ca_crt" {
  value = tls_self_signed_cert.etcd_ca.cert_pem
}

output "k8s_apiserver_etcd_client_key" {
  value = tls_private_key.k8s_apiserver_etcd_client.private_key_pem
}

output "k8s_apiserver_etcd_client_crt" {
  value = tls_locally_signed_cert.k8s_apiserver_etcd_client.cert_pem

}

output "k8s_serviceaccount_pub" {
  value = tls_private_key.k8s_serviceaccount.public_key_pem
}

output "k8s_serviceaccount_key" {
  value = tls_private_key.k8s_serviceaccount.private_key_pem
}

output "k8s_apiserver_key" {
  value = tls_private_key.k8s_apiserver.private_key_pem
}

output "k8s_apiserver_crt" {
  value = tls_locally_signed_cert.k8s_apiserver.cert_pem

}
