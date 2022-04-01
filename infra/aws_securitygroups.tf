resource "aws_security_group" "controller" {
  vpc_id      = aws_vpc.vpc.id
  description = "Controller Group"
}

resource "aws_security_group_rule" "k8s_api_to_controller" {
  description = "All k8s_api from to the controller"

  type      = "ingress"
  from_port = 6443
  to_port   = 6443
  protocol  = "TCP"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "controller_to_controller" {
  description = "All traffic from the controller to the controller"

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  self = true

  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "worker_to_controller" {
  description = "All traffic from the worker to the controller"

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.controller.id
}
resource "aws_security_group_rule" "bastion_to_controller" {
  description = "All traffic from the bastion to the controller"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "TCP"

  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "controller_to_everywhere" {
  description = "All outgoing traffic from the controller"

  type      = "egress"
  from_port = 0
  protocol  = "-1"
  to_port   = 0

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group" "worker" {
  vpc_id      = aws_vpc.vpc.id
  description = "Worker Group"
}

resource "aws_security_group_rule" "controller_to_worker" {
  description = "All traffic from the controller to the worker"

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.worker.id
}


resource "aws_security_group_rule" "worker_to_worker" {
  description = "All traffic from the worker to the worker"

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  self = true

  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "bastion_to_worker" {
  description = "All traffic from the bastion to the worker"

  type      = "ingress"
  from_port = 0
  protocol  = "-1"
  to_port   = 0

  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_to_everywhere" {
  description = "All traffic from the worker to the worker"

  type      = "egress"
  from_port = 0
  protocol  = "-1"
  to_port   = 0

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.worker.id
}


resource "aws_security_group" "bastion" {
  description = "Allow bastion traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "K8s from everywhere"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
