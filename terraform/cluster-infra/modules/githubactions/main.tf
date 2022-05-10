resource "aws_iam_openid_connect_provider" "github_actions" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.thumbprint
  url             = "https://token.actions.githubusercontent.com"
}


