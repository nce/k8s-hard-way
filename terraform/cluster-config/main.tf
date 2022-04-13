module "bootstrap" {
  source = "./modules/kubelet-bootstrap"

  bootstrap_token_id = data.aws_ssm_parameter.configs["k8s_kubelet_bootstrap_token_id"].value
  bootstrap_token    = data.aws_ssm_parameter.secrets["k8s_kubelet_bootstrap_token"].value

}
