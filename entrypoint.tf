module "product_dynamo" {
  source              = "./modules/dynamoDB"
  name                = "productDB"
  hash_key            = "AppName"
}

resource "aws_iam_role" "lambda_code_commit" {
  name = "iam_for_repo_lambda"

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
    name   = "policy-lambda-codecommit"
    policy = data.aws_iam_policy_document.codeCommit.json
  }

}

data "aws_iam_policy_document" "codeCommit" {
  statement {
    actions   = ["codecommit:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions   = ["dynamodb:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions   = ["ssm:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions   = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
    resources = ["*"]
    effect = "Allow"
  }
}

data "archive_file" "repoCreate" {
  type        = "zip"
  source_dir = "${path.module}/scripts/repoCreateLambda/"
  output_path = "${path.module}/files/repoCreateLambda.zip"
}

module "initial_lambda" {
  source        = "./modules/lambda"
  depends_on    = [
    data.archive_file.repoCreate
  ]
  role_arn      = aws_iam_role.lambda_code_commit.arn
  runtime       = "python3.7"
  function_name = var.repo_create_lambda_name
  handler       = "repo.main"
  file_path     = "${abspath(path.module)}/files/repoCreateLambda.zip"
}