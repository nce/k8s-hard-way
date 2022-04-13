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
