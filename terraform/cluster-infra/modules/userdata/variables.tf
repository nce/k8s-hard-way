variable "files" {
  type = map(map(object({ content = string, user = string, group = string, mode = string })))
}

variable "k8s_cluster_name" {
  type = string
}

variable "k8s_controlplane_count" {
  type = number
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
