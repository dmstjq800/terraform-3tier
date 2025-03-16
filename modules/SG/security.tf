#######################################
# Security Group 생성
resource "aws_security_group" "WEBSG" {
  name = "WEBSG"
  description = "Allow HTTP (80)"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80 
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "WEBSG"
  }
}
resource "aws_security_group" "WASSG" {
  name = "WASSG"
  description = "Allow HTTP (8080)"
  vpc_id = var.vpc_id
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "WASSG"
  }
}
resource "aws_security_group" "DBSG" {
  name = "DBSG"
  description = "Allow MySQL (3306)"
  vpc_id = var.vpc_id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "DBSG"
  }
}
##################################
# IAM 역할 생성
resource "aws_iam_role" "ec2role" {
  name = "ec2role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
################################
# IAM 정책 생성
resource "aws_iam_role_policy" "s3" {
  name = "s3"
  role = aws_iam_role.ec2role.id 
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "AllowAppArtifactsReadAccess",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "ec2" {
  name = "ec2"
  role = aws_iam_role.ec2role.id 
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}
######################################
# IAM 인스턴스 프로필 생성
resource "aws_iam_instance_profile" "iamprofile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2role.name
}