variable "repo_create_lambda_name" {
  type    = string
  default = "repoCreate"
}

variable "connector_lambda_name" {
  type    = string
  default = "pipelineConnector"
}

variable "bucket_name" {
  type    = string
  default = "devops-backend-122334"
}