resource "aws_iam_instance_profile" "this" {
  name = "${var.cluster_name}-${var.k8s_component_type}"
  path = "/${var.cluster_name}/kubernetes/"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = "${var.cluster_name}-${var.k8s_component_type}"
  path               = "/${var.cluster_name}/kubernetes/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "ignition" {
  bucket = var.s3_ignition_bucket.id
  policy = data.aws_iam_policy_document.ignition.json
}

data "aws_iam_policy_document" "ignition" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      var.s3_ignition_bucket.arn,
      "${var.s3_ignition_bucket.arn}/*",
    ]
  }
}
