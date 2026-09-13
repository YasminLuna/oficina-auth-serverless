provider "aws" { region = var.aws_region }

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../build"
  output_path = "${path.module}/lambda.zip"
}
#lmb

resource "aws_iam_role" "lambda" {
  name = "oficina-auth-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "auth" {
  function_name    = "oficina-auth-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 10
  memory_size      = 256

  environment {
    variables = {
      DATABASE_URL                = var.database_url
      JWT_SECRET                  = var.jwt_secret
      ACCESS_TOKEN_EXPIRE_MINUTES = "60"
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.lambda_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.lambda_subnet_ids
      security_group_ids = var.lambda_security_group_ids
    }
  }
}

resource "aws_apigatewayv2_api" "auth" {
  name          = "oficina-auth-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "auth" {
  api_id                 = aws_apigatewayv2_api.auth.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "token" {
  api_id    = aws_apigatewayv2_api.auth.id
  route_key = "POST /auth/token"
  target    = "integrations/${aws_apigatewayv2_integration.auth.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.auth.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "gateway" {
  statement_id  = "AllowApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.auth.execution_arn}/*/*"
}
