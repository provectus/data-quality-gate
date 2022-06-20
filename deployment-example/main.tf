terraform {
  backend "s3" {
  }
}

module "data_qa_gate" {
  source = "../"
}

