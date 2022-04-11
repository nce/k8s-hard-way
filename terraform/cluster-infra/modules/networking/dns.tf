data "aws_route53_zone" "root_zone" {
  name = var.dns_root_zone
}

resource "aws_route53_zone" "dns" {
  name = "${var.k8s_cluster_name}.${data.aws_route53_zone.root_zone.name}"
}

resource "aws_route53_record" "main_zone_NS" {
  zone_id = data.aws_route53_zone.root_zone.id
  name    = aws_route53_zone.dns.name
  type    = "NS"

  ttl = "300"

  records = aws_route53_zone.dns.name_servers
}
