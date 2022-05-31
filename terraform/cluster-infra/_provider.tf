variable "aws_profile" {
  type    = string
  default = ""
}

provider "aws" {
  region  = "eu-central-1"
  profile = var.aws_profile

  default_tags {
    tags = {
      project = "ugo-k8s"
      Owner   = "ugo"
      Name    = "ugo-k8s"
    }
  }
}

provider "echo" {}
