terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4"
    }
  }
}

provider "aws" {
  region = var.region
  //shared_config_files = var.shared_config_files
  //profile             = "terraformuser"
}