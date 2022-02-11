provider "aws" {
  region  = "eu-central-1"
  profile = "adorsys-sandbox"

  default_tags {
    tags = {
      owner = "ugo"
      name  = "k8s-hard-way"
    }
  }

}
