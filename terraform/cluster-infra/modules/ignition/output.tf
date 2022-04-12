output "user_data" {
  value = local.user_data
}

output "bucket_arn" {
  value = aws_s3_bucket.ignition.arn
}

output "ignition_s3_policy_arn" {
  value = aws_iam_policy.ignition_s3.arn
}
