resource "aws_s3_bucket" "ignition" {
  bucket = "${var.k8s_cluster_name}-ignition-configs"
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

