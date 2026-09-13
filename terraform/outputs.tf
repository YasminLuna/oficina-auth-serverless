output "auth_url" { value = "${aws_apigatewayv2_api.auth.api_endpoint}/auth/token" }
output "lambda_name" { value = aws_lambda_function.auth.function_name }
