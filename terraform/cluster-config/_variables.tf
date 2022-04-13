variable "k8s_version" {
  description = "Version of kubernetes"
  type        = string

  default = "1.23.5"
}

variable "k8s_cluster_name" {
  description = "Mnemonic Name of the kubernetes Kluster"
  type        = string

  default = "ugo-k8s"
}

variable "k8s_api_extern" {
  description = "api Name of the k8sapi"
  type        = string

  default = "api.ugo-k8s.adorsys-sandbox.aws.adorsys.de"
}

variable "aws_vpc_cni_k8s" {
  description = "Helm Chart Version"
  type        = string

  default = "1.1.12"
}

variable "kubelet_csr_approver_version" {
  description = "Helm Chart Version"
  type        = string

  default = "0.2.2"
}
