data "tls_certificate" "k8s_api" {
  url          = "https://${var.k8s_api_extern}"
  verify_chain = false
}

resource "aws_iam_openid_connect_provider" "k8s" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.k8s_api.certificates[0].sha1_fingerprint]
  url             = "https://${var.k8s_api_extern}"
}
