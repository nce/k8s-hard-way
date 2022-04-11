module "systemsmanager" {
  source = "./modules/systemsmanager"

  k8s_cluster_name = var.k8s_cluster_name
}

module "networking" {
  source = "./modules/networking"

  aws_vpc_cidr     = var.aws_vpc_cidr
  k8s_cluster_name = var.k8s_cluster_name
  dns_root_zone    = var.dns_root_zone
}

module "securitygroups" {
  source = "./modules/securitygroups"

  vpc_id = module.networking.vpc_id
}

module "publick8sapi" {
  source = "./modules/publick8sapi"

  k8s_cluster_name = var.k8s_cluster_name

  vpc_id        = module.networking.vpc_id
  aws_subnets   = module.networking.private_subnets
  dns_main_zone = module.networking.dns_main_zone
}

module "pki" {
  source = "./modules/pki"

  k8s_api_extern = var.k8s_api_extern
  k8s_service_ip = var.k8s_service_ip

}

module "clusterfiles" {
  source = "./modules/clusterfiles"

  k8s_cluster_name = var.k8s_cluster_name

  etcd_version          = var.etcd_version
  etcd_discovery_domain = var.etcd_discovery_domain
  k8s_version           = var.k8s_version
  k8s_cluster_dns       = var.k8s_cluster_dns
  k8s_api_extern        = var.k8s_api_extern
  k8s_service_cidr      = var.k8s_service_cidr

  k8s_pki_ca_crt                       = module.pki.ca_crt
  k8s_pki_ca_key                       = module.pki.ca_key
  k8s_pki_apiserver_etcd_client_key    = module.pki.k8s_apiserver_etcd_client_key
  k8s_pki_apiserver_etcd_client_crt    = module.pki.k8s_apiserver_etcd_client_crt
  k8s_pki_apiserver_kubelet_client_key = module.pki.k8s_apiserver_kubelet_client_key
  k8s_pki_apiserver_kubelet_client_crt = module.pki.k8s_apiserver_kubelet_client_crt
  etcd_pki_ca_key                      = module.pki.etcd_ca_key
  etcd_pki_ca_crt                      = module.pki.etcd_ca_crt
  etcd_pki_peer_crt                    = module.pki.etcd_peer_crt
  etcd_pki_peer_key                    = module.pki.etcd_peer_key
  etcd_pki_server_crt                  = module.pki.etcd_server_crt
  etcd_pki_server_key                  = module.pki.etcd_server_key
  k8s_pki_serviceaccount_pub           = module.pki.k8s_serviceaccount_pub
  k8s_pki_serviceaccount_key           = module.pki.k8s_serviceaccount_key
  k8s_pki_apiserver_crt                = module.pki.k8s_apiserver_crt
  k8s_pki_apiserver_key                = module.pki.k8s_apiserver_key
  k8s_pki_scheduler_crt                = module.pki.k8s_scheduler_crt
  k8s_pki_scheduler_key                = module.pki.k8s_scheduler_key
  k8s_pki_controller_manager_crt       = module.pki.k8s_controller_manager_crt
  k8s_pki_controller_manager_key       = module.pki.k8s_controller_manager_key
  k8s_pki_admin_crt                    = module.pki.k8s_admin_crt
  k8s_pki_admin_key                    = module.pki.k8s_admin_key


}

module "controlplane_userdata" {
  source = "./modules/userdata"

  k8s_cluster_name = var.k8s_cluster_name

  k8s_kubernetes_version = var.k8s_version
  k8s_kubelet_sha512     = var.k8s_kubelet_sha512
  k8s_kubectl_sha512     = var.k8s_kubectl_sha512

  files = merge(
    module.clusterfiles.controlplane_configs
  )
}

module "etcd_dns_discovery" {
  source = "./modules/etcddnsdiscovery"

  vpc_id                = module.networking.vpc_id
  etcd_discovery_domain = var.etcd_discovery_domain
}

module "controlplane" {
  source = "./modules/controlplane"

  k8s_version            = var.k8s_version
  k8s_cluster_name       = var.k8s_cluster_name
  k8s_controlplane_count = var.k8s_controlplane_count

  aws_vpc_id          = module.networking.vpc_id
  aws_private_subnets = module.networking.private_subnets
  aws_security_group_ids = [
    module.securitygroups.controlplane.id
  ]

  aws_instance_type = var.aws_instance_type

  user_data = module.controlplane_userdata.user_data

  aws_iam_role_policy_attachments = [
    module.systemsmanager.iam_role_policy_arn,
    module.controlplane_userdata.ignition_s3_policy_arn
  ]

  etcd_discovery_zone_id = module.etcd_dns_discovery.zone_id
  etcd_discovery_domain  = var.etcd_discovery_domain

  awslb_apiserver_targetgroup_arn = module.publick8sapi.awslb_apiserver_targetgroup_arn
}
