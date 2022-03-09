terraform {
  required_version = ">= 0.15"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
      #version = "< 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.13"
    }
  }
}
