variable "k8s_version" {
  type = string
}

variable "k8s_cluster_name" {
  type = string
}

variable "k8s_controlplane_count" {
  type = number
}

variable "awslb_apiserver_targetgroup_arn" {
  type = string
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

variable "aws_iam_role_policy_attachments" {
  type = list(string)
}

variable "user_data" {
  type = string
}

variable "etcd_discovery_zone_id" {
  type = string
}

variable "etcd_discovery_domain" {
  type = string
}

