output "awslb_apiserver_targetgroup_arn" {
  value = aws_lb_target_group.k8s_api.arn
}
