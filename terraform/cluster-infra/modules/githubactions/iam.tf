resource "aws_iam_role" "github_actions" {
  name               = "ugo-github-actions"
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.github_actions.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:nce/k8s-hard-way:*"
        }
      }
    }
  ]
}
JSON
}

data "aws_iam_policy" "ViewOnlyAccess" {
  name = "ViewOnlyAccess"
}
data "aws_iam_policy" "IAMReadOnlyAccess" {
  name = "IAMReadOnlyAccess"
}

resource "aws_iam_role_policy" "github_actions_readonly" {
  name   = "ViewOnlyAccess"
  policy = data.aws_iam_policy.ViewOnlyAccess.policy
  role   = aws_iam_role.github_actions.id
}

resource "aws_iam_role_policy" "github_actions_iamreadonly" {
  name   = "IAMReadOnlyAccess"
  policy = data.aws_iam_policy.IAMReadOnlyAccess.policy
  role   = aws_iam_role.github_actions.id
}
