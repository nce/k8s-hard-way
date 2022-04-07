module "instanceprofile" {
  source = "../../modules/instanceprofile"

  name        = var.k8s_cluster_name
  policy_arns = concat(var.aws_iam_role_policy_attachments)
}
