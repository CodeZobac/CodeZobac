terraform {
  required_version = ">= 1.9.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

# AWS provider for ACM certificate management must exist in us-east-1
# LINK: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-certificate-issuer
provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}
