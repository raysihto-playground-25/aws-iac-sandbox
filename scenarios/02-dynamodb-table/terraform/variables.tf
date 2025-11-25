variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "table_prefix" {
  description = "Prefix for DynamoDB table name"
  type        = string
  default     = "iac-learning-table"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "learning"
}
