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

variable "vpc_id" {
  type    = string
  default = ""
}

variable "ec2_subnets" {
  type = list(string)
  default = []
}

variable "inbound_cidr" {
  type = string
  default = "0.0.0.0/0"
}

locals {

build_user_data = templatefile("${path.module}/scripts/userdatas/buildAgent.sh.tpl", {
    bucket_name = var.bucket_name
})

}
