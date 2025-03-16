###############################
# Target Group 생성
resource "aws_alb_target_group" "myTG" {
  vpc_id = var.vpc_id 
  port = 8080 ## 로드밸런서 8080포트로 접속시 타겟 8080포트로 연결
  protocol = "HTTP"
  name = "was-alb-tg"
}
##############################
# ALB 생성
resource "aws_alb" "myALB" {
  name = "was-alb"
  load_balancer_type = "application"
  internal = true  
  security_groups = [ var.security_group_id ]
  subnets = var.private_subnet_id
}
#######################################
# ALB listener 생성
resource "aws_alb_listener" "ALB_listener" {
  load_balancer_arn = aws_alb.myALB.arn 
  port = 8080
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.myTG.arn 
  }
}
#######################################
# 시작템플릿 생성
resource "aws_launch_template" "was_launch_template" {
  name = "was_launch_template"
  image_id = "ami-075e056c0f3d02523"
  instance_type = "t2.micro"
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    DB_DNS=var.db_dns
  }))
  vpc_security_group_ids = [ var.security_group_id ]
  iam_instance_profile {
    arn = var.iam_role_profile_arn
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "was-template"
    }
  }
}
######################################
# AutoScalingGroup 생성 및 연결
resource "aws_autoscaling_group" "myASG" {
  name = "wasasg"
  min_size = 1
  max_size = 5
  desired_capacity = 1
  health_check_grace_period = 30 
  health_check_type = "EC2"
  force_delete = false
  vpc_zone_identifier = var.private_subnet_id
  launch_template {
    id = aws_launch_template.was_launch_template.id 
    version = "$Latest"
  }
}
resource "aws_autoscaling_attachment" "myASG_attachment" {
  autoscaling_group_name = aws_autoscaling_group.myASG.id 
  lb_target_group_arn = aws_alb_target_group.myTG.arn
}