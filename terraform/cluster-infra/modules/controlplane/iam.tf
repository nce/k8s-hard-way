module "instanceprofile" {
  source = "../../modules/instanceprofile"
  count  = var.k8s_controlplane_count

  name        = "${var.k8s_cluster_name}-controlplane-${count.index}"
  policy_arns = var.aws_iam_role_policy_attachments[count.index]
}
