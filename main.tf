terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.74"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  shared_credentials_file = "/Users/jalenmak/.aws/shared_credentials_file"
}
