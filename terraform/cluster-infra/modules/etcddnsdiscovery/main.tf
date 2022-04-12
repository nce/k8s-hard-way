resource "aws_route53_zone" "etcd" {
  name = var.etcd_discovery_domain

  force_destroy = true

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "etcd_discovery_domain" {
  zone_id = aws_route53_zone.etcd.id
  name    = "_etcd-server-ssl._tcp.${var.etcd_discovery_domain}"

  type = "SRV"
  ttl  = "60"

  records = [for i in range(0, var.k8s_controlplane_count) :
    "0 0 2380 etcd${i}.${var.etcd_discovery_domain}"
  ]

}
