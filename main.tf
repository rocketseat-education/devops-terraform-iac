terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }

  backend "s3" {
    bucket  = "rocketseat-iac"
    key     = "state/terraform.tfstate"
    region  = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "rocketseat-iac"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = "rocketseat-iac"
  versioning_configuration {
    status = "Enabled"
  }
}
