module "systemsmanager" {
  source = "./modules/systemsmanager"

  k8s_cluster_name = var.k8s_cluster_name
}

module "networking" {
  source = "./modules/networking"

  aws_vpc_cidr     = var.aws_vpc_cidr
  k8s_cluster_name = var.k8s_cluster_name
}

module "securitygroups" {
  source = "./modules/securitygroups"

  vpc_id = module.networking.vpc_id
}

module "controlplane_clusterfiles" {
  source = "./modules/clusterfiles"

  k8s_cluster_name = var.k8s_cluster_name
}

module "controlplane_userdata" {
  source = "./modules/userdata"

  k8s_cluster_name = var.k8s_cluster_name

  files = merge(
    module.controlplane_clusterfiles.controlplane_configs
  )
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

  user_data = module.controlplane_userdata.user_data

  aws_iam_role_policy_attachments = [
    module.systemsmanager.iam_role_policy_arn,
    module.controlplane_userdata.ignition_s3_policy_arn
  ]
}
