resource "helm_release" "kubelet_csr_approver" {
  chart      = "kubelet-csr-approver"
  name       = "kubelet-csr-approver"
  repository = "https://postfinance.github.io/kubelet-csr-approver"
  version    = var.chart_version
  namespace  = "kube-system"

  atomic  = true
  lint    = true
  timeout = 45

  values = [<<YAML
providerRegex: "^ip-[a-z0-9-_]*(\\.eu-central-1\\.compute\\.internal)?$"
#tolerations:
# - key: node.kubernetes.io/not-ready
#   effect: NoSchedule
# - key: node-role.kubernetes.io/master
#   effect: NoSchedule
YAML
  ]
}
