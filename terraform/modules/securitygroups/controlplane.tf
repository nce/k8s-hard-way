resource "aws_security_group" "controlplane" {
  description = "Controlplane Group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ssh_to_controlplane" {
  description = "All ipv4 ssh traffic to the controlplane"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "TCP"

  security_group_id = aws_security_group.controlplane.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controlpane_to_everywhere" {
  description = "All outgoing traffic from the controlplane"

  type      = "egress"
  from_port = 0
  protocol  = "-1"
  to_port   = 0

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.controlplane.id
}


