provider "aws" {
  region  = "eu-central-1"
  profile = "adorsys-sandbox"

  default_tags {
    tags = {
      Owner = "ugo"
      Name  = "k8s-hard-way"
    }
  }

}
