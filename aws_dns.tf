data "aws_route53_zone" "adorsys_sandbox" {
  name = "adorsys-sandbox.aws.adorsys.de."
}

resource "aws_route53_zone" "dns" {
  name = "ugo-k8s.${data.aws_route53_zone.adorsys_sandbox.name}"
}

resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.dns.id
  name    = "bastion.${aws_route53_zone.dns.name}"
  type    = "A"

  ttl     = "300"
  records = [aws_instance.bastion.public_ip]
}


resource "aws_route53_record" "adorsys_sandbox_aws_adorsys_de_NS" {
  zone_id = data.aws_route53_zone.adorsys_sandbox.id
  name    = aws_route53_zone.dns.name
  type    = "NS"

  ttl = "300"

  records = aws_route53_zone.dns.name_servers
}
