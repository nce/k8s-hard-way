# in 0.6.6 IRSA is still not working
resource "helm_release" "aws_cloud_controller_manager" {
  chart      = "aws-cloud-controller-manager"
  name       = "aws-cloud-controller-manager"
  repository = "https://kubernetes.github.io/cloud-provider-aws"
  version    = var.chart_version
  namespace  = "kube-system"

  atomic  = true
  lint    = true
  timeout = 45

  # v1.23.0 is no starting due to version string regex matching
  values = [<<YAML
image:
  tag: v1.23.2
hostNetworking: true
extraVolumeMounts:
${module.irsa_aws_cloud_controller_manager.extraVolumeMounts}
extraVolumes:
${module.irsa_aws_cloud_controller_manager.extraVolumes}
env:
${module.irsa_aws_cloud_controller_manager.env}
serviceAccountName: aws-cloud-controller-manager
args:
  - --v=2
  - --cloud-provider=aws
  - --cluster-name=${var.k8s_cluster_name}
  - --configure-cloud-routes=false
  - --enable-leader-migration
YAML
  ]
}

