module "bootstrap" {
  source = "./modules/kubelet-bootstrap"

  bootstrap_token_id = data.aws_ssm_parameter.configs["k8s_kubelet_bootstrap_token_id"].value
  bootstrap_token    = data.aws_ssm_parameter.secrets["k8s_kubelet_bootstrap_token"].value

}

# setup module for irsa
module "iam-roles-for-serviceaccounts" {
  source = "./modules/iam-roles-for-serviceaccounts"

  k8s_api_extern = var.k8s_api_extern
}

# we need a proxy to route to our service_ip; without that
# the vpc cni is not reaching the api server via default ENV Var
# KUBERNETES_SERVICE
module "kube_proxy" {
  source = "./modules/kube-proxy"

  k8s_api_extern = var.k8s_api_extern
  k8s_version    = var.k8s_version
}

# does not need a vpc if we run in host network
# which might be a better solution anyway, as its a core component
module "aws_cloud_controller_manager" {
  source = "./modules/aws-cloud-controller-manager"

  chart_version    = var.aws_cloud_controller_manager_version
  k8s_cluster_name = var.k8s_cluster_name
  k8s_api_extern   = var.k8s_api_extern
}

module "aws-vpc-cni-k8s" {
  source = "./modules/aws-vpc-cni-k8s"

  chart_version = var.aws_vpc_cni_k8s
}

# with the csr approver the apiserver can access the kubelet
# after this we have 'ready' nodes
module "kubelet-csr-approver" {
  source = "./modules/kubelet-csr-approver"

  chart_version = var.kubelet_csr_approver_version
}


