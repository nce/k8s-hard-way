module "networking" {
  source = "./modules/networking"

  aws_vpc_cidr     = var.aws_vpc_cidr
  k8s_cluster_name = var.k8s_cluster_name
}

module "securitygroups" {
  source = "./modules/securitygroups"

  vpc_id = module.networking.vpc_id
}

module "controlplane" {
  source = "./modules/controlplane"

  k8s_version          = var.k8s_version
  k8s_cluster_name     = var.k8s_cluster_name
  k8s_controller_count = var.k8s_controller_count

  aws_vpc_id          = module.networking.vpc_id
  aws_private_subnets = module.networking.private_subnets
  aws_security_group_ids = [
    module.securitygroups.controlplane.id
  ]

  aws_instance_type  = var.aws_instance_type
  aws_ssh_public_key = var.ssh_public_key
}
