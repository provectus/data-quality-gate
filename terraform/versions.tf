terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
  }
  required_version = "~> 1.1"
}
