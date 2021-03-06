variable "k8s_version" {
  description = "Version of kubernetes"
  type        = string

  default = "1.23.5"
}

variable "k8s_cluster_name" {
  description = "Mnemonic Name of the kubernetes Kluster"
  type        = string

  default = "ugo-k8s"
}

variable "k8s_controlplane_count" {
  description = "Initial controlplane size"
  type        = number

  default = 3
}

variable "etcd_discovery_domain" {
  description = "Internal domain for the etcd dns discovery"
  type        = string

  default = "ugo-k8s.etcd.svc"
}

variable "aws_instance_type" {
  description = "AWS Instance type of the controller"
  type        = string

  default = "t4g.small"
}

variable "kubelet_max_pods" {
  # for aws vpc
  # number of ENIs for the instance type × (the number of IPs per ENI - 1)) + 2
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html
  description = "Max Pods per Kubelet"
  type        = number

  default = 11
}

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string

  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFldffWdqC4BTSXVya3tEc7gihX0L+COYinDQuu6kaG/ ull@m1"
}

variable "aws_vpc_cidr" {
  description = "Cluster VPC cidr block"
  type        = string

  default = "10.10.0.0/16"
}

variable "k8s_kubectl_sha512" {
  description = "Checksum of kubectl"
  type        = string

  default = "f06216fc596b831cee2a4946e5442454685838c1542f3aa93d0f52bb25433f670a3451e0188ddf2049f37026d1cf5bbfe8ec6eb2866daf81cfbe3073a9984ea9"
}

variable "k8s_kubelet_sha512" {
  description = "Checksum of kubelet"
  type        = string

  default = "3a103d584fff10d3f2378f6f654aee761977514f4a995f8f58966e5ffaa4a7dfbb24aeed33ef9fa09280c43ba8b87b8772e1f349ef529c67822dcfa68941a688"
}

variable "k8s_api_extern" {
  description = "api Name of the k8sapi"
  type        = string

  default = "api.ugo-k8s.adorsys-sandbox.aws.adorsys.de"
}

variable "k8s_service_ip" {
  description = "Ip Adress of the default kuberentes svc"
  type        = string

  default = "10.32.0.1"
}

variable "k8s_service_cidr" {
  description = "CIDR of k8s services"
  type        = string

  default = "10.32.0.0/24"
}

variable "etcd_version" {
  description = "Version of etcd image"
  type        = string

  # https://quay.io/repository/coreos/etcd?tab=tags
  default = "3.5.2"
}

variable "k8s_cluster_dns" {
  description = "IP of dns server"
  type        = string

  default = "10.32.0.53"
}

variable "dns_root_zone" {
  description = "Root DNS Zone"

  default = "adorsys-sandbox.aws.adorsys.de."
}

# https://gist.github.com/guitarrapc/8e6b68f21bc1eef8e7b66bde477d5859?permalink_comment_id=4027755
variable "github_thumbprint" {
  description = "Githubusercontent Cert Thumbprint"

  default = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

