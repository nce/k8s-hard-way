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

output "k8s_apiserver_kubelet_client_key" {
  value = tls_private_key.k8s_apiserver_kubelet_client.private_key_pem
}

output "k8s_apiserver_kubelet_client_crt" {
  value = tls_locally_signed_cert.k8s_apiserver_kubelet_client.cert_pem
}

output "k8s_controller_manager_key" {
  value = tls_private_key.k8s_controller_manager.private_key_pem
}

output "k8s_controller_manager_crt" {
  value = tls_locally_signed_cert.k8s_controller_manager.cert_pem
}

output "k8s_scheduler_key" {
  value = tls_private_key.k8s_scheduler.private_key_pem
}

output "k8s_scheduler_crt" {
  value = tls_locally_signed_cert.k8s_scheduler.cert_pem
}

output "k8s_admin_key" {
  value = tls_private_key.k8s_admin.private_key_pem
}

output "k8s_admin_crt" {
  value = tls_locally_signed_cert.k8s_admin.cert_pem
}

output "etcd_peer_crt" {
  value = tls_locally_signed_cert.k8s_etcd_peer[*].cert_pem
}

output "etcd_peer_key" {
  value = tls_private_key.k8s_etcd_peer[*].private_key_pem
}

output "etcd_server_crt" {
  value = tls_locally_signed_cert.k8s_etcd_server[*].cert_pem
}

output "etcd_server_key" {
  value = tls_private_key.k8s_etcd_server[*].private_key_pem
}
