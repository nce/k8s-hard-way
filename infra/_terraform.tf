terraform {
  required_version = ">= 0.15"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2"
    }
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.0"
      version = "< 4.0"
    }
  }
}
