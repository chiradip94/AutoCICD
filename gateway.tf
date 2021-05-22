module "api_gateway_main" {
  source = "./modules/apiGateway"
  gateway_name = "AutoCICD"
  path_part    = "create"
  lambda_uri   = module.initial_lambda.invoke_arn
  stage_name   = "final"
}

resource "aws_lambda_permission" "repoCreate_lambda_permission" {
  statement_id  = "APIinvokeToInitialLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.repo_create_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${module.api_gateway_main.execution_arn}/*/*/*"
}

output "invoke_url" {
  value = module.api_gateway_main.invoke_url
}