resource "aws_api_gateway_rest_api" "AutoCICD" {
  name        = var.gateway_name
}

resource "aws_api_gateway_resource" "this" {
   rest_api_id = aws_api_gateway_rest_api.AutoCICD.id
   parent_id   = aws_api_gateway_rest_api.AutoCICD.root_resource_id
   path_part   = var.path_part
}

resource "aws_api_gateway_method" "this" {
   rest_api_id   = aws_api_gateway_rest_api.AutoCICD.id
   resource_id   = aws_api_gateway_resource.this.id
   http_method   = "POST"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.AutoCICD.id
   resource_id = aws_api_gateway_method.this.resource_id
   http_method = aws_api_gateway_method.this.http_method

   integration_http_method = "POST"
   type                    = "AWS"
   uri                     = var.lambda_uri
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.AutoCICD.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "this" {
  depends_on  = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.AutoCICD.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "this" {
   depends_on  = [aws_api_gateway_integration.lambda]
   rest_api_id = aws_api_gateway_rest_api.AutoCICD.id

   lifecycle {
      create_before_destroy = true
   }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.AutoCICD.id
  stage_name    = var.stage_name
}