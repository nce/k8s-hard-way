resource "aws_security_group" "controller" {
  vpc_id      = aws_vpc.vpc.id
  description = "Controller Group"

}

resource "aws_security_group_rule" "bastion_to_controller" {
  description = "All traffic from the bastion to the controller"

  type      = "ingress"
  from_port = 0
  protocol  = "-1"
  to_port   = 0

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

resource "aws_security_group_rule" "aws_ingress" {
  description = "API Traffic from controller to worker"

  type      = "ingress"
  from_port = 9443
  to_port   = 9443
  protocol  = "tcp"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]


  security_group_id = aws_security_group.worker.id
}


resource "aws_security_group_rule" "k8sapi" {
  description = "API Traffic from worker to controlnode"

  type      = "ingress"
  from_port = 6443
  to_port   = 6443
  protocol  = "tcp"

  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "ssh_to_controller" {
  description = "SSH from bastion to controller"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.controller.id
}

resource "aws_security_group_rule" "ssh_to_worker" {
  description = "SSH from bastion to worker"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "etcd_to_controller" {
  description = "Etcd from controller to controller"

  type      = "ingress"
  from_port = 2379
  to_port   = 2380
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller.id
}

resource "aws_security_group_rule" "scheduler_from_controller" {
  description = "Scheduler from controller to controller"

  type      = "ingress"
  from_port = 10259
  to_port   = 10259
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller.id
}

resource "aws_security_group_rule" "controllermanager_from_controller" {
  description = "Controllermanager from controller to controller"

  type      = "ingress"
  from_port = 10257
  to_port   = 10257
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller.id
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

resource "aws_security_group_rule" "proxy_from_controller" {
  description = "Proxy from controller to worker"

  type      = "ingress"
  from_port = 10249
  to_port   = 10249
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "kubelet_from_controller" {
  description = "kubelet from controller to worker"

  type      = "ingress"
  from_port = 10250
  to_port   = 10250
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "kubelet_from_controller_to_controller" {
  description = "kubelet from controller to controller"

  type      = "ingress"
  from_port = 10250
  to_port   = 10250
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller.id
}

resource "aws_security_group_rule" "proxy_from_controller_to_controller" {
  description = "proxy from controller to controller"

  type      = "ingress"
  from_port = 10249
  to_port   = 10249
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller.id
}

resource "aws_security_group_rule" "bgp_from_controller_to_controller" {
  description = "bgp from controller to controller"

  type      = "ingress"
  from_port = 179
  to_port   = 179
  protocol  = "tcp"

  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller.id
}
