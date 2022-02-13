
resource "aws_security_group" "controller" {
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    # https://www.weave.works/docs/net/latest/faq/
    for_each = {
      6781 : { protocol : "tcp", description : "weave metrics" },
      6782 : { protocol : "tcp", description : "weave metrics" },
      6783 : { protocol : "tcp", description : "weave control" },
      6783 : { protocol : "udp", description : "weave control" },
      6784 : { protocol : "udp", description : "weave control" },
    }

    content {
      description = ingress.value.description

      from_port = ingress.key
      protocol  = ingress.value.protocol
      to_port   = ingress.value.protocol == "icmp" ? 0 : ingress.key

      self = true
    }
  }

  dynamic "ingress" {
    # https://kubernetes.io/docs/reference/ports-and-protocols/
    for_each = {
      22 : { protocol : "tcp", description : "ssh" },
      6443 : { protocol : "tcp", description : "apiserver" },
      2379 : { protocol : "tcp", description : "etcd apiserver" },
      2380 : { protocol : "tcp", description : "etcd" },
      10250 : { protocol : "tcp", description : "kubelet api" },
      10259 : { protocol : "tcp", description : "kubescheduler" },
      10257 : { protocol : "tcp", description : "kube controller manager" },
    }

    content {
      description = ingress.value.description

      from_port = ingress.key
      protocol  = ingress.value.protocol
      to_port   = ingress.value.protocol == "icmp" ? 0 : ingress.key

      self = true
    }
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "bastion_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

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
