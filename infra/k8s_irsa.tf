data "tls_certificate" "k8s_api" {
  url          = "https://${aws_route53_record.k8s_api.name}"
  verify_chain = false
}

resource "aws_iam_openid_connect_provider" "k8s" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.k8s_api.certificates[0].sha1_fingerprint]
  url             = "https://${aws_route53_record.k8s_api.name}"
}

resource "kubectl_manifest" "crb_irsa" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: public-oidc-api
subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:service-account-issuer-discovery
  apiGroup: rbac.authorization.k8s.io
YAML
}

resource "aws_iam_role" "external_dns" {
  name               = "ugo-externaldns"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::571075516563:oidc-provider/api.ugo-k8s.adorsys-sandbox.aws.adorsys.de"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "api.ugo-k8s.adorsys-sandbox.aws.adorsys.de:aud": "sts.amazonaws.com",
          "api.ugo-k8s.adorsys-sandbox.aws.adorsys.de:sub": "system:serviceaccount:kube-system:external-dns"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_policy" "external_dns" {
  name = "k8sExternalDns"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "kubectl_manifest" "secret_irsa" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: irsa-webhook
  namespace: kube-system
  labels:
type: kubernetes.io/tls
data:
  tls.crt: |
    ${indent(4, base64encode(tls_locally_signed_cert.k8s_irsa.cert_pem))}
  tls.key: |
    ${indent(4, base64encode(tls_private_key.k8s_irsa.private_key_pem))}
YAML
}
