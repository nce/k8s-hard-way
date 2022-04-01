resource "aws_lb" "k8s_api" {
  name = "ugo-k8s-api"

  internal = false

  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.subnet : subnet.id]
}

resource "aws_lb_target_group" "k8s_api" {
  name = "ugo-k8s-apiserver"
  port = 6443

  protocol    = "TCP"
  target_type = "instance"

  vpc_id = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "k8s_api" {
  count = var.controller_instances

  target_group_arn = aws_lb_target_group.k8s_api.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 6443
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.k8s_api.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api.arn
  }
}
