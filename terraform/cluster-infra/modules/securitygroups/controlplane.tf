resource "aws_security_group" "controlplane" {
  description = "Controlplane Group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "controlpane_to_everywhere" {
  description = "All outgoing traffic from the controlplane"

  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.controlplane.id
}

resource "aws_security_group_rule" "world_to_controlplane" {
  description = "Traffic from world to the apiserver"

  type      = "ingress"
  from_port = 6443
  to_port   = 6443
  protocol  = "TCP"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.controlplane.id
}


