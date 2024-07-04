terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4"
    }
  }
}

provider "aws" {
  region              = var.region
  shared_config_files = var.shared_config_files
  profile             = "terraformuser"
}

terraform {
  backend "s3" {
    bucket  = "terrforms3-remote-backend"
    key     = "global/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

resource "aws_s3_bucket" "tfbucket" {
  bucket = "terrforms3-remote-backend"

  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.tfbucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
