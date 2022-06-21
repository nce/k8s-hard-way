resource "helm_release" "kubelet_csr_approver" {
  chart      = "kubelet-csr-approver"
  name       = "kubelet-csr-approver"
  repository = "https://postfinance.github.io/kubelet-csr-approver"
  version    = var.chart_version
  namespace  = "kube-system"

  atomic  = true
  lint    = true
  timeout = 70

  values = [<<YAML
providerRegex: "^i-[a-z0-9-_]*(\\.eu-central-1\\.compute\\.internal)?$"
YAML
  ]
}
