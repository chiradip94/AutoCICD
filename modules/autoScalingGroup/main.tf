data "aws_ami" "linux" {
  most_recent      = true
  owners           = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210427.0-x86_64-gp2"]
  }
}

resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = var.name
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

inline_policy {
    name   = var.name
    policy = data.aws_iam_policy_document.this.json
  }
}



data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["codecommit:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions   = ["ssm:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions   = ["s3:*"]
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



resource "aws_launch_configuration" "this" {
  name             = var.name
  image_id         = data.aws_ami.linux.id
  key_name         = var.key_name
  security_groups  = [aws_security_group.this.id]
  instance_type    = var.instance_type
  user_data        = var.userdata
  iam_instance_profile = aws_iam_instance_profile.this.name
}


resource "aws_autoscaling_policy" "this" {
  name                   = var.name
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

resource "aws_autoscaling_group" "this" {
  vpc_zone_identifier       = var.ec2_subnets
  name                      = var.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 560
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.this.name
}

resource "aws_security_group" "this" {
  name        = var.name
  description = "for build and deploy agent"
  vpc_id      = var.vpc_id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.inbound_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
