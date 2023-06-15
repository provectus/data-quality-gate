terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.8.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
  }
  required_version = "~> 1.1"
}
