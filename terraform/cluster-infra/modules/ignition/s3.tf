resource "aws_s3_bucket" "ignition" {
  bucket = "${var.k8s_cluster_name}-ignition-controlplane-${var.index}"
}

resource "aws_s3_bucket_acl" "ignition" {
  bucket = aws_s3_bucket.ignition.bucket
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "ignition" {
  bucket = aws_s3_bucket.ignition.id

  restrict_public_buckets = true

  block_public_acls   = true
  block_public_policy = true

  ignore_public_acls = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ignition" {
  bucket = aws_s3_bucket.ignition.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_policy" "ignition_s3" {
  name   = "${var.k8s_cluster_name}-controlplane-s3-${var.index}"
  path   = "/${var.k8s_cluster_name}/"
  policy = data.aws_iam_policy_document.ignition.json
}

data "aws_iam_policy_document" "ignition" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.ignition.arn,
      "${aws_s3_bucket.ignition.arn}/*",
    ]
  }
}
