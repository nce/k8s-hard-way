resource "kubectl_manifest" "secret_token" {

  depends_on = [
    kubectl_manifest.crb_node_bootstrappers,
    kubectl_manifest.crb_approve_csr_new,
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  # Name MUST be of form "bootstrap-token-<token id>"
  name: bootstrap-token-${var.bootstrap_token_id}
  namespace: kube-system
# Type MUST be 'bootstrap.kubernetes.io/token'
type: bootstrap.kubernetes.io/token
stringData:
  description: "Token for kubelet auth"

  # Token ID and secret. Required.
  token-id: ${var.bootstrap_token_id}
  token-secret: ${var.bootstrap_token}

  #expiration: 2017-03-10T03:22:11Z
  # Allowed usages.
  usage-bootstrap-authentication: "true"
YAML
}
