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

resource "aws_security_group_rule" "dns_in_controlplane" {
  for_each          = toset(["TCP", "UDP"])
  security_group_id = aws_security_group.controlplane.id
  description       = "DNS in Controlplane"

  from_port = 53
  to_port   = 53
  protocol  = each.key
  type      = "ingress"

  self = true
}

resource "aws_security_group_rule" "etcd_in_controlplane" {
  description = "ETCD in controlplane"

  from_port = 2379
  to_port   = 2380
  protocol  = "TCP"
  type      = "ingress"

  self              = true
  security_group_id = aws_security_group.controlplane.id
}

resource "aws_security_group_rule" "kubelet_in_controlplane" {
  description = "Kubelet in controlplane"

  from_port = 10250
  to_port   = 10250
  protocol  = "TCP"
  type      = "ingress"

  self              = true
  security_group_id = aws_security_group.controlplane.id
}
