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
