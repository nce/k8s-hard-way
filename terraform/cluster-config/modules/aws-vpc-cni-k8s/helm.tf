resource "helm_release" "aws_vpc_cni_k8s" {
  chart      = "aws-vpc-cni"
  name       = "aws-vpc-cni"
  repository = "https://aws.github.io/eks-charts"
  version    = var.chart_version
  namespace  = "kube-system"

  atomic          = true
  cleanup_on_fail = true
  lint            = true
  timeout         = 60

  values = [<<YAML
cniConfig:
  region: eu-central-1
eniConfig:
  create: true
  region: eu-central-1
  subnets: {}
serviceaccount:
  name: aws-vpc-cni
init:
  image:
    region: eu-central-1
image:
  region: eu-central-1
  tag: v1.11.2
env:
  AWS_VPC_K8S_PLUGIN_LOG_FILE: stderr
  AWS_VPC_K8S_CNI_LOG_FILE: stdout
  AWS_VPC_K8S_CNI_EXTERNALSNAT: true
  CLUSTER_NAME: ${var.k8s_cluster_name}
  ENABLE_PREFIX_DELEGATION: true
  AWS_VPC_CNI_NODE_PORT_SUPPORT: true
cri:
  hostPath:
    path: /var/run/containerd/containerd.sock
YAML
  ]
}
#ENIConfig
#    - id: subnet-034f5d03888353286
#    - id: subnet-0e3af6ee983edaa9b

