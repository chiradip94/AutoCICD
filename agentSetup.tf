resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_ssm_parameter" "tfBackend" {
  name  = "/devops/s3/backend/name"
  type  = "String"
  value = var.bucket_name
}

resource "aws_s3_bucket_object" "build_python" {
  key        = "userdata/buildAgent.py"
  bucket     = aws_s3_bucket.backend.id
  source     = "${path.module}/scripts/userdatas/buildAgent.py"
}

module "build_asg" {
  source        = "./modules/autoScalingGroup"
  depends_on    = [aws_s3_bucket_object.build_python]
  name          = "buildAgent"
  ec2_subnets   = var.ec2_subnets
  vpc_id        = var.vpc_id
  inbound_cidr  = var.inbound_cidr
  userdata      = base64encode(var.build_user_data)
}
