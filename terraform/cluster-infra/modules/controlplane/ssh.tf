resource "aws_key_pair" "admin" {
  key_name   = "${var.k8s_cluster_name}-admin"
  public_key = var.aws_ssh_public_key
}
