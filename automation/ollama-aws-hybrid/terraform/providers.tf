terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.53.0"
    }
  }
  required_version = "~> 1.15.0"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
