output "auth_url" {
  value = "${aws_apigatewayv2_api.auth.api_endpoint}/auth/token"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.auth.api_endpoint
}

output "lambda_name" {
  value = aws_lambda_function.auth.function_name
}

output "jwt_secret_arn" {
  value = aws_secretsmanager_secret.jwt.arn
}

output "lambda_security_group_id" {
  value = var.vpc_id != "" ? aws_security_group.lambda[0].id : null
}
