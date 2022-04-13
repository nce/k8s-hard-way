resource "kubectl_manifest" "cm_kubeproxy_config" {

  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-proxy
  namespace: kube-system
binaryData:
  config.yaml: |
    ${indent(4, base64encode(file("${path.module}/files/config.yaml")))}
  kubeconfig.yaml: |
    ${indent(4, base64encode(templatefile("${path.module}/files/kubeconfig.yaml", {
  k8s_api_extern = var.k8s_api_extern
})))}
YAML
}
