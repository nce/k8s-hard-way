output "controller_ips" {
  value = aws_instance.controller.*.private_ip
}
