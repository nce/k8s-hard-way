resource "aws_instance" "instance" {
  count = var.instance_count

  tags = {
    Name                                        = "${var.cluster_name}-${var.k8s_component_type}-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  instance_type = var.aws_instance_type
  ami           = data.aws_ami.flatcar.id

  key_name = aws_key_pair.ugo.key_name

  user_data                   = local.user_data
  user_data_replace_on_change = true


  subnet_id = var.private_subnets[
    keys(data.aws_availability_zone.all)[
      (count.index) % length(keys(data.aws_availability_zone.all))
    ]
  ]

  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.this.name

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

locals {
  user_data = <<EOF
{
  "ignition": {
    "version": "3.3.0",
    "config": {
      "replace": {
        "source": "s3://ugo-k8s-ignition-configs/controlplane-${sha512(var.user_data)}.ignition",
        "verification": {
          "hash": "sha512-${sha512(var.user_data)}"
        }
      }
    }
  }
}
EOF
}
