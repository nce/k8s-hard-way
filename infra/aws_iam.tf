resource "aws_iam_user" "ingress_lb" {
  name = "ugo-k8s-ingress"
  path = "/"
}

resource "aws_iam_access_key" "ingress_lb" {
  user = aws_iam_user.ingress_lb.name
}

resource "aws_iam_policy" "policy" {
  name   = "iam_aws_lb"
  policy = file("aws-lb-controller/iam_policy.json")
}

#resource "aws_iam_user_policy" "ingress_lb_ro" {
#  user = aws_iam_user.ingress_lb.name
#
#  policy = file("aws-lb-controller/iam_policy.json")
#}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.ingress_lb.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "kubectl_manifest" "aws_iam_token" {

  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
data:
  keyid: ${base64encode(aws_iam_access_key.ingress_lb.id)}
  keysecret: ${base64encode(aws_iam_access_key.ingress_lb.secret)}
kind: Secret
metadata:
  name: awscredentials
  namespace: kube-system
type: Opaque
YAML
}

