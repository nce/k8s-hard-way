resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current}:oidc-provider/${var.issuer}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.issuer}:aud": "sts.amazonaws.com",
          "${var.issuer}:sub": "${var.sub}"
        }
      }
    }
  ]
}
JSON
}

resource "aws_iam_role_policy" "this" {
  name   = var.name
  policy = var.policy
  role   = aws_iam_role.this.id
}
