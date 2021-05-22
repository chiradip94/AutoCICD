resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_ssm_parameter" "tfBackend" {
  name  = "/devops/s3/backend/name"
  type  = "String"
  value = var.bucket_name
}