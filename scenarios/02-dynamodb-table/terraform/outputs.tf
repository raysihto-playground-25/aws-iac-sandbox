output "table_name" {
  description = "Name of the created DynamoDB table"
  value       = aws_dynamodb_table.learning_table.name
}

output "table_arn" {
  description = "ARN of the created DynamoDB table"
  value       = aws_dynamodb_table.learning_table.arn
}

output "table_id" {
  description = "ID of the created DynamoDB table"
  value       = aws_dynamodb_table.learning_table.id
}
