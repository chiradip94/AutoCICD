resource "aws_lambda_function" "test_lambda" {
  filename      = var.file_path
  function_name = var.function_name
  role          = var.role_arn
  handler       = var.handler
  source_code_hash = filebase64sha256(var.file_path)
  runtime = var.runtime
}