resource "helm_release" "aws_vpc_cni_k8s" {
  chart      = "aws-vpc-cni"
  name       = "aws-vpc-cni"
  repository = "https://aws.github.io/eks-charts"
  version    = var.chart_version
  namespace  = "kube-system"

  atomic  = true
  lint    = true
  timeout = 45

  values = [<<YAML
eniConfig:
  region: eu-central-1
serviceaccount:
  name: aws-vpc-cni
init:
  image:
    region: eu-central-1
image:
  region: eu-central-1
env:
  AWS_VPC_K8S_PLUGIN_LOG_FILE: stderr
  AWS_VPC_K8S_CNI_LOG_FILE: stdout
cri:
  hostPath:
    path: /var/run/containerd/containerd.sock
YAML
  ]
}
