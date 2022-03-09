provider "aws" {
  region  = "eu-central-1"
  profile = "adorsys-sandbox"

  default_tags {
    tags = {
      Owner = "ugo"
      Name  = "ugo-k8s-hard-way"
    }
  }
}

provider "kubectl" {
  load_config_file = true
  config_path      = "./admin.kubeconfig"
}
