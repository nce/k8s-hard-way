resource "aws_lb_target_group_attachment" "k8s_api" {
  count = var.k8s_controlplane_count

  #target_group_arn = aws_lb_target_group.k8s_api.arn
  target_group_arn = var.awslb_apiserver_targetgroup_arn
  target_id        = aws_instance.instance[count.index].id
  port             = 6443
}


