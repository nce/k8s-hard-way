variable "k8s_pki_ca_crt" {
  type = string
}

variable "k8s_username" {
  type = string
}

variable "k8s_api" {
  type = string
}

variable "k8s_cluster_name" {
  type = string
}

variable "k8s_pki_client_crt" {
  type    = string
  default = null
}

variable "k8s_pki_client_key" {
  type    = string
  default = null
}

variable "k8s_token" {
  type    = string
  default = null
}
