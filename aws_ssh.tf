resource "aws_key_pair" "ugo" {
  key_name   = "ugo"
  public_key = var.ssh_public_key
}
