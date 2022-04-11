variable "k8s_cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_subnets" {
  type = map(any)
}

variable "dns_main_zone" {
  type = any
}
