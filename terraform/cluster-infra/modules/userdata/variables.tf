variable "files" {
  type = map(object({ content = string, user = string, group = string, mode = string }))
}

variable "k8s_cluster_name" {
  type = string
}
