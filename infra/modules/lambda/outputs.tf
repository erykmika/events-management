output "lambda_function_arn" {
  value = aws_lambda_function.process_images.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.process_images.function_name
}
