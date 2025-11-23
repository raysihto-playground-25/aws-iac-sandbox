terraform {
  required_version = ">= 1.6"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate random suffix for unique table name
resource "random_string" "table_suffix" {
  length  = 8
  special = false
  upper   = false
}

# DynamoDB table
resource "aws_dynamodb_table" "learning_table" {
  name           = "${var.table_prefix}-${random_string.table_suffix.result}"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand pricing (free tier friendly)
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption {
    enabled = true
  }

  # Enable TTL
  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }

  tags = {
    Name        = "IaC Learning DynamoDB Table"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Learning IaC tools comparison"
  }
}
