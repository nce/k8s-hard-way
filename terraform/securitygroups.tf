module "securitygroups" {
  source = "./modules/securitygroups"

  vpc_id = module.networking.vpc_id
}
