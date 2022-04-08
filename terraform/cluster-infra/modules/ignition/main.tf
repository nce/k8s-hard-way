locals {
  file_snippets = [for filename, attr in var.files : templatefile("${path.module}/templates/s3_files.yaml", {
    path   = filename,
    mode   = attr.mode,
    user   = attr.user,
    group  = attr.group,
    bucket = aws_s3_bucket.ignition.bucket,
    hash   = sha512(attr.content)
  })]

  user_data = <<EOF
{
  "ignition": {
    "version": "3.3.0",
    "config": {
      "replace": {
        "source": "s3://${aws_s3_object.ignition_setup.bucket}/setup.ignition",
        "verification": {
          "hash": "sha512-${sha512(data.ct_config.ignition.rendered)}"
        }
      }
    }
  }
}
EOF

}

data "ct_config" "ignition" {
  content      = jsonencode({})
  strict       = true
  pretty_print = true

  snippets = concat(local.file_snippets, var.snippets)

  platform = "ec2"
}

# upload ignition file
resource "aws_s3_object" "ignition_setup" {

  bucket = aws_s3_bucket.ignition.id
  key    = "/setup.ignition"

  content = data.ct_config.ignition.rendered

  server_side_encryption = "AES256"
  etag                   = md5(data.ct_config.ignition.rendered)
  source_hash            = md5(data.ct_config.ignition.rendered)
}

