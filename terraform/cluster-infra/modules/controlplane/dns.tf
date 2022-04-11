resource "aws_route53_record" "etcd" {
  name = "etcd0.${var.etcd_discovery_domain}"

  type = "A"
  ttl  = "60"

  records = [
    aws_instance.instance[0].private_ip
  ]

  zone_id = var.etcd_discovery_zone_id
}
