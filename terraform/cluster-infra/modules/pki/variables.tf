variable "k8s_api_extern" {
  type = string
}

variable "k8s_service_ip" {
  type = string
}

variable "k8s_controlplane_count" {
  type = number
}

variable "etcd_discovery_domain" {
  type = string
}
