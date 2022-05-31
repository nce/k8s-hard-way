terraform {

  backend "s3" {
    bucket  = "adorsys-sandbox-terraform-state-files"
    region  = "eu-central-1"
    profile = "adorsys-sandbox"
    key     = "ugo/k8s-hard-way/cluster-infra/terraform.state"

    encrypt = true
  }

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
    echo = {
      source  = "jkroepke/echo"
      version = "~> 0.1.0"
    }
  }
}
