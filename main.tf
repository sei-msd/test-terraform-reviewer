terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Simple S3 Bucket for testing
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-test-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-test-bucket"
    Environment = var.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}