variable "instance_count" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "aws_instance_type" {
  type = string
}

variable "k8s_component_type" {
  type = string

  validation {
    condition     = contains(["controlplane", "worker"], var.k8s_component_type)
    error_message = "Must be 'controlpane' or 'worker'."
  }
}

variable "ssh_key" {
  type = string
}

variable "private_subnets" {
  type = map(string)
}

variable "security_group_ids" {
  type = list(any)
}

variable "s3_ignition_bucket" {
  type = any
}

variable "user_data" {
  type = string
}
