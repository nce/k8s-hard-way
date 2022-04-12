resource "aws_route53_record" "etcd" {
  count = var.k8s_controlplane_count

  name = "etcd${count.index}.${var.etcd_discovery_domain}"

  type = "A"
  ttl  = "60"

  records = [
    aws_instance.instance[count.index].private_ip
  ]

  zone_id = var.etcd_discovery_zone_id
}
