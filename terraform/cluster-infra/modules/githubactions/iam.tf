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

resource "aws_iam_policy_attachment" "ViewOnlyS3" {
  name       = "ViewOnlyS3"
  policy_arn = aws_iam_policy.s3_tf_bucket.arn
  roles      = [aws_iam_role.github_actions.name]
}

data "aws_iam_policy" "ViewOnlyAccess" {
  name = "ViewOnlyAccess"
}
data "aws_iam_policy" "IAMReadOnlyAccess" {
  name = "IAMReadOnlyAccess"
}

resource "aws_iam_policy" "s3_tf_bucket" {
  name   = "s3TfBucket"
  path   = "/${var.k8s_cluster_name}/"
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::adorsys-sandbox-terraform-state-files"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::adorsys-sandbox-terraform-state-files/ugo/k8s-hard-way/cluster-infra/terraform.state"
    }
  ]
}
JSON
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

resource "aws_iam_policy" "lb" {
  name   = "ViewOnlyLB"
  path   = "/${var.k8s_cluster_name}/"
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:Describe*"],
      "Resource": "*"
    }
  ]
}
JSON
}

resource "aws_iam_policy_attachment" "ViewOnlyLB" {
  name       = "ViewOnlyLB"
  policy_arn = aws_iam_policy.lb.arn
  roles      = [aws_iam_role.github_actions.name]
}

resource "aws_iam_policy" "acm" {
  name   = "ViewOnlyACM"
  path   = "/${var.k8s_cluster_name}/"
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["acm:Describe*", "acm:List*"],
      "Resource": "arn:aws:acm:eu-central-1:${local.account_id}:certificate/*"
    }
  ]
}
JSON
}

resource "aws_iam_policy_attachment" "ViewOnlyACM" {
  name       = "ViewOnlyACM"
  policy_arn = aws_iam_policy.acm.arn
  roles      = [aws_iam_role.github_actions.name]
}

resource "aws_iam_policy" "ssm" {
  name   = "ViewOnlySSM"
  path   = "/${var.k8s_cluster_name}/"
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ssm:Get*","ssm:Describe*", "ssm:List*"],
      "Resource": "arn:aws:ssm:eu-central-1:${local.account_id}:*"
    }
  ]
}
JSON
}

resource "aws_iam_policy_attachment" "ViewOnlySSM" {
  name       = "ViewOnlySSM"
  policy_arn = aws_iam_policy.ssm.arn
  roles      = [aws_iam_role.github_actions.name]
}

# TODO: this needs major refactoring
# for each for each bucket; instead of 3 policies
resource "aws_iam_policy" "controlplane_s3_buckets" {
  count  = 3
  name   = "ViewOnlyS3Controlplane${count.index}"
  path   = "/${var.k8s_cluster_name}/"
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:List*", "s3:Get*"],
      "Resource": "arn:aws:s3:::${var.k8s_cluster_name}-ignition-controlplane-${count.index}"
    },{
      "Effect": "Allow",
      "Action": ["s3:Get*"],
      "Resource": "arn:aws:s3:::${var.k8s_cluster_name}-ignition-controlplane-${count.index}/*"
    }
  ]
}
JSON
}

resource "aws_iam_policy_attachment" "ViewOnlyS3Controlplane" {
  count      = 3
  name       = "ViewOnlySSM${count.index}"
  policy_arn = aws_iam_policy.controlplane_s3_buckets[count.index].arn
  roles      = [aws_iam_role.github_actions.name]
}
