resource "local_file" "k8s_api_lb" {

  content = templatefile("api-lb/api-lb.sh.tftpl", {
    apiservers = aws_instance.controller.*.private_ip
  })

  filename = "./api-lb/generated/api-lb.sh"

  depends_on = [aws_instance.controller]
}

resource "null_resource" "k8s_apilb_bastion" {

  depends_on = [
    local_file.k8s_api_lb,
    null_resource.k8s_bastion_baseos
  ]

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = "./api-lb/generated/api-lb.sh"
    destination = "api-lb.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x api-lb.sh",
      "sudo ./api-lb.sh"
    ]
  }
}
