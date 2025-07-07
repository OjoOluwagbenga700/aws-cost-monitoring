output "lambda_function_names" {
  description = "Names of the created Lambda functions"
  value = {
    for k, lambda in aws_lambda_function.lambda_function : k => lambda.function_name
  }
}