output "controlplane_configs" {
  value = local.files_controlplane_configs
}

output "kubeconfig_admin" {
  value = module.kubeconfig_admin.kubeconfig
}
