resource "aws_instance" "instance" {
  count = var.k8s_controller_count

  tags = {
    Name                                            = "${var.k8s_cluster_name}-controlplane-${count.index}"
    "kubernetes.io/cluster/${var.k8s_cluster_name}" = "owned"
  }

  instance_type = var.aws_instance_type
  ami           = data.aws_ami.flatcar.id

  key_name = aws_key_pair.admin.key_name

  subnet_id = var.aws_private_subnets[
    keys(data.aws_availability_zone.all)[
      (count.index) % length(keys(data.aws_availability_zone.all))
    ]
  ]

  vpc_security_group_ids      = var.aws_security_group_ids
  associate_public_ip_address = true

  # iam_instance_profile = aws_iam_instance_profile.this.name

  metadata_options {
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  root_block_device {
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle {
    # should be true later
    create_before_destroy = false
  }
}
