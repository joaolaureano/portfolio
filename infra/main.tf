terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# CloudFront only accepts ACM certificates from us-east-1, so everything lives
# there: one region, one provider, nothing to keep in sync.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "opentofu"
    }
  }
}

data "aws_caller_identity" "current" {}
