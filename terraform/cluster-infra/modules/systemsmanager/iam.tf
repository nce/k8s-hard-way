resource "aws_iam_policy" "ssm" {
  name   = "${var.k8s_cluster_name}-ssm"
  path   = "/${var.k8s_cluster_name}/"
  policy = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "ssm" {
  source_policy_documents = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.policy,
    data.aws_iam_policy.CloudWatchAgentServerPolicy.policy,
  ]
}
