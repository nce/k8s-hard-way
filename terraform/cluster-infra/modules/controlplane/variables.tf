variable "k8s_version" {
  type = string
}

variable "k8s_cluster_name" {
  type = string
}

variable "k8s_controller_count" {
  type = number
}

variable "aws_instance_type" {
  type = string
}

variable "aws_ssh_public_key" {
  type = string
}

variable "aws_private_subnets" {
  type = map(string)
}

variable "aws_vpc_id" {
  type = string
}

variable "aws_security_group_ids" {
  type = list(any)
}
