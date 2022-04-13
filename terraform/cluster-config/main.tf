module "bootstrap" {
  source = "./modules/kubelet-bootstrap"

  bootstrap_token_id = data.aws_ssm_parameter.configs["k8s_kubelet_bootstrap_token_id"].value
  bootstrap_token    = data.aws_ssm_parameter.secrets["k8s_kubelet_bootstrap_token"].value

}

module "aws-vpc-cni-k8s" {
  source = "./modules/aws-vpc-cni-k8s"

  chart_version = var.aws_vpc_cni_k8s
}

#module "kubelet-csr-approver" {
#  source = "./modules/kubelet-csr-approver"
#
#  chart_version = var.kubelet_csr_approver_version
#}

module "iam-roles-for-serviceaccounts" {
  source = "./modules/iam-roles-for-serviceaccounts"

  k8s_api_extern = var.k8s_api_extern
}

#module "aws_cloud_controller_manager" {
#  source = "./modules/aws-cloud-controller-manager"
#}
