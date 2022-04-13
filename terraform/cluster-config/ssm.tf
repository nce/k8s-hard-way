data "aws_ssm_parameter" "secrets" {
  for_each = toset([
    "k8s_kubelet_bootstrap_token"
  ])

  name            = "/${var.k8s_cluster_name}/secret/${each.key}"
  with_decryption = true
}

data "aws_ssm_parameter" "configs" {
  for_each = toset([
    "k8s_kubelet_bootstrap_token_id"
  ])

  name = "/${var.k8s_cluster_name}/config/${each.key}"
}

