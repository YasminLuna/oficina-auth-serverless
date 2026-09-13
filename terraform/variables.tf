variable "aws_region" { type = string, default = "us-east-1" }
variable "environment" { type = string, default = "hml" }
variable "database_url" { type = string, sensitive = true }
variable "jwt_secret" { type = string, sensitive = true }
variable "lambda_subnet_ids" { type = list(string), default = [] }
variable "lambda_security_group_ids" { type = list(string), default = [] }
