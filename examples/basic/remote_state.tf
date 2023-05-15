terraform {
  backend "s3" {
    bucket  = "fast-data-qa-terraform"
    key     = "terraform/state/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}