output "bastion_ip_public" {
  value = aws_instance.bastion.public_ip
}
output "bastion_ip_private" {
  value = aws_instance.bastion.private_ip
}
output "controller_ips" {
  value = aws_instance.controller.*.private_ip
}
output "first_controller_ip" {
  value = aws_instance.controller[0].private_ip
}
output "worker_ips" {
  value = aws_instance.worker.*.private_ip
}

