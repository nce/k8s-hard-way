resource "aws_s3_object" "ignition" {
  for_each = var.files

  bucket  = aws_s3_bucket.ignition.bucket
  key     = each.key
  content = each.value.content

  server_side_encryption = "AES256"

  etag        = md5(each.value.content)
  source_hash = md5(each.value.content)
}
