resource "aws_iam_role" "lambda_connector" {
  name = "iam_for_connector_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

inline_policy {
    name   = "policy-lambda-connector"
    policy = data.aws_iam_policy_document.codeCommit.json
  }

}

data "aws_iam_policy_document" "connector" {
  statement {
    actions   = ["dynamodb:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions   = ["sqs:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

data "archive_file" "connector" {
  type        = "zip"
  source_dir = "${path.module}/scripts/connectorLambda/"
  output_path = "${path.module}/files/connectorLambda.zip"
}

module "connector_lambda" {
  source        = "./modules/lambda"
  depends_on    = [
    data.archive_file.repoCreate
  ]
  role_arn      = aws_iam_role.lambda_connector.arn
  runtime       = "python3.7"
  function_name = var.connector_lambda_name
  handler       = "repo.main"
  file_path     = "${abspath(path.module)}/files/repoCreateLambda.zip"
}

module "build_sqs" {
  source   = "./modules/sqs"
  sqs_name = "DevOps-Build"
}

module "deploy_sqs" {
  source   = "./modules/sqs"
  sqs_name = "DevOps-Deploy"
}