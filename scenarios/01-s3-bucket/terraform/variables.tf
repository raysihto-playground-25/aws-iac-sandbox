variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket name"
  type        = string
  default     = "iac-learning-bucket"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "learning"
}
