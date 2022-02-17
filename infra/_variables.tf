variable "ssh_public_key" {
  type = string
}

variable "main_vpc_cidr" {
  type = string
}

variable "controller_instances" {
  type = number
}

variable "cluster_service_ip" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "etcd_version" {
  type = string
}
