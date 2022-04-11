resource "aws_lb" "k8s_api" {
  name = "api-${var.k8s_cluster_name}"

  internal = false

  load_balancer_type = "network"
  subnets            = [for az, s in var.aws_subnets : s]
}

resource "aws_lb_target_group" "k8s_api" {
  name = "${var.k8s_cluster_name}-apiserver"
  port = 6443

  protocol    = "TCP"
  target_type = "instance"

  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "k8s_api" {
  load_balancer_arn = aws_lb.k8s_api.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api.arn
  }
}

resource "aws_route53_record" "k8s_api" {
  zone_id = var.dns_main_zone.id
  name    = "api.${var.dns_main_zone.name}"
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_lb.k8s_api.dns_name
    zone_id                = aws_lb.k8s_api.zone_id
  }
}
