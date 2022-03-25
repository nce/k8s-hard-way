resource "aws_acm_certificate" "k8s" {
  domain_name       = aws_route53_zone.dns.name
  validation_method = "DNS"

  subject_alternative_names = ["*.${aws_route53_zone.dns.name}"]
}

resource "aws_acm_certificate_validation" "k8s" {
  certificate_arn         = aws_acm_certificate.k8s.arn
  validation_record_fqdns = [for record in aws_route53_record.k8s_validation : record.fqdn]
}

resource "aws_route53_record" "k8s_validation" {
  for_each = {
    for dvo in aws_acm_certificate.k8s.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type

  zone_id = aws_route53_zone.dns.id
  ttl     = 60

}
