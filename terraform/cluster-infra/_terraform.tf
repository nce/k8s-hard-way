terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "~> 0.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1"
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
