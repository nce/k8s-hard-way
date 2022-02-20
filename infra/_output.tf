output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
output "controller_ips" {
  value = aws_instance.controller.*.private_ip
}
output "worker_ips" {
  value = aws_instance.worker.*.private_ip
}

