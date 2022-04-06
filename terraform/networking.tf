module "networking" {
  source = "./modules/networking"

  vpc_cidr     = var.main_vpc_cidr
  cluster_name = var.k8s_cluster_name
}
