# userdata rendered controlplane
output "controlplane_user_data_rendered" {
  value = data.ct_config.controlplane.rendered
}

# userdata rendered worker
