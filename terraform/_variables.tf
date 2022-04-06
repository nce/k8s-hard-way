variable "kubernetes_version" {
  description = "Version of kubernetes"
  type        = string

  default = "1.23.5"
}

variable "kubectl_sha512" {
  description = "Checksum of kubectl"
  type        = string

  default = "f06216fc596b831cee2a4946e5442454685838c1542f3aa93d0f52bb25433f670a3451e0188ddf2049f37026d1cf5bbfe8ec6eb2866daf81cfbe3073a9984ea9"
}

variable "kubelet_sha512" {
  description = "Checksum of kubelet"
  type        = string

  default = "3a103d584fff10d3f2378f6f654aee761977514f4a995f8f58966e5ffaa4a7dfbb24aeed33ef9fa09280c43ba8b87b8772e1f349ef529c67822dcfa68941a688"
}

variable "etcd_version" {
  description = "Version of etcd image"
  type        = string

  # https://quay.io/repository/coreos/etcd?tab=tags
  default = "3.5.2"
}

variable "k8s_pod_cidr" {
  description = "CIDR of all pods in the cluster"
  type        = string

  default = "10.200.0.0/16"
}

variable "k8s_cluster_dns" {
  description = "CIDR of all pods in the cluster"
  type        = string

  default = "10.32.0.53"
}

variable "main_vpc_cidr" {
  description = "Cluster VPC private cidr block"
  type        = string

  default = "10.10.0.0/16"
}

variable "k8s_cluster_name" {
  description = "Mnemonic Name of the kubernetes Kluster"
  type        = string

  default = "ugo-k8s"
}

variable "aws_controlplane_instance_type" {
  description = "AWS Instance type of the controller"
  type        = string

  default = "t4g.small"
}

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string

  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFldffWdqC4BTSXVya3tEc7gihX0L+COYinDQuu6kaG/ ull@m1"

}
