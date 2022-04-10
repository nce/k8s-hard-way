variable "k8s_cluster_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "etcd_version" {
  type = string
}

variable "k8s_cluster_dns" {
  type = string
}

variable "k8s_api_extern" {
  type = string
}

variable "k8s_service_cidr" {
  type = string
}

variable "k8s_pki_ca_crt" {
  type = string
}

variable "k8s_pki_ca_key" {
  type = string
}

variable "etcd_pki_ca_key" {
  type = string
}

variable "etcd_pki_ca_crt" {
  type = string
}

variable "k8s_pki_apiserver_etcd_client_key" {
  type = string
}

variable "k8s_pki_apiserver_etcd_client_crt" {
  type = string
}

variable "k8s_pki_serviceaccount_pub" {
  type = string
}

variable "k8s_pki_serviceaccount_key" {
  type = string
}

variable "k8s_pki_apiserver_key" {
  type = string
}

variable "k8s_pki_apiserver_crt" {
  type = string
}
