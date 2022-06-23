terraform {
  backend "s3" {
  }
}

module "data_qa_gate" {
  source = "../"
  aws_region = "eu-central-1"
}

