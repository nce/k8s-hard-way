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
## which might be a better solution anyway, as its a core component
# Nodelabeler Systemd services needs to run for this
# as the ds is selecting on this label for master node
# CNI needs to be available; as there are no tolerations
# for kubelet not ready, which is ready after the cni
#
# E0601 12:56:57.873916       1 node_controller.go:213] error syncing 'ip-10-10-148-251': failed to get provider ID for node ip-10-10-148-251 at cloudprovider: failed to get instance ID from cloud provider: instance not found, requeuing
#
# => RBN in the subnet
module "aws_cloud_controller_manager" {
  source = "./modules/aws-cloud-controller-manager"

  chart_version    = var.aws_cloud_controller_manager_version
  k8s_api_extern   = var.k8s_api_extern
  k8s_cluster_name = var.k8s_cluster_name

}

# CNI not working with 
#   Warning  FailedCreatePodSandBox  2m40s             kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network for sandbox "5a156b99f77d0d53d679b5baaefd2094df28d6d575a37334d33e85454935
# abb2": plugin type="loopback" failed (add): incompatible CNI versions; config is "1.0.0", plugin supports ["0.1.0" "0.2.0" "0.3.0" "0.3.1" "0.4.0"]
#
# AWS VPC Subnet config not needed as its picked up correctly
#
# Found availability zone: eu-central-1b
# Discovered the instance primary IPv4 address: 10.10.173.15
# Found instance-type: t4g.small
# Found subnet-id: subnet-0a5bb0c1c84b6d146
# => kubelet external cloudprovider was not set
module "aws-vpc-cni-k8s" {
  source = "./modules/aws-vpc-cni-k8s"

  chart_version    = var.aws_vpc_cni_k8s
  k8s_cluster_name = var.k8s_cluster_name
}

# with the csr approver the apiserver can access the kubelet
# which is needed for logs & exec
# after this we have really 'ready' nodes
module "kubelet-csr-approver" {
  source = "./modules/kubelet-csr-approver"

  chart_version = var.kubelet_csr_approver_version
}
#
##
