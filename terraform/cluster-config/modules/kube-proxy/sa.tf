resource "kubectl_manifest" "sa_kube_proxy" {

  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-proxy
  namespace: kube-system
YAML
}
