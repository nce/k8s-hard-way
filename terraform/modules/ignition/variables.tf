variable "k8s_etcd_version" {
  type = string
}

variable "k8s_cluster_dns" {
  type = string
}

variable "k8s_kubernetes_version" {
  type = string
}

variable "k8s_kubectl_sha512" {
  type = string
}

variable "k8s_kubelet_sha512" {
  type = string
}

variable "s3_ignition_bucket" {
  type = string
}

variable "k8s_pki_ca_cert" {
  type = string
}

variable "k8s_pki_ca_key" {
  type = string
}
