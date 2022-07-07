provider "aws" {
  region  = "eu-central-1"
  profile = "adorsys-sandbox"

  default_tags {
    tags = {
      project = "ugo-k8s"
      Owner   = "ugo"
      Name    = "ugo-k8s"
    }
  }
}

provider "kubectl" {
  load_config_file = true
  config_path      = "~/.kube/configs/hardway_${var.k8s_cluster_name}.kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/configs/hardway_${var.k8s_cluster_name}.kubeconfig"
  }
}
