module "controlplane" {
  source = "./modules/instances"

  instance_count     = 1
  k8s_component_type = "controlplane"
  aws_instance_type  = var.aws_controlplane_instance_type
  cluster_name       = var.k8s_cluster_name
  ssh_key            = var.ssh_public_key

  private_subnets = module.networking.private_subnets
  security_group_ids = [
    module.securitygroups.controlplane.id
  ]

  s3_ignition_bucket = aws_s3_bucket.ignition

  user_data = module.ignition.controlplane_user_data_rendered
}

