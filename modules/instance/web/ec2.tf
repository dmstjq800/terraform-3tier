###################################
# Target Group 생성
resource "aws_alb_target_group" "myTG" {
  vpc_id = var.vpc_id
  port = 80
  protocol = "HTTP"
  name = "web-alb-tg"
}
##################################
# ALB 생성
resource "aws_alb" "myALB" {
  name = "web-alb"
  load_balancer_type = "application"
  security_groups = [ var.vpc_security_group_id ]
  subnets = var.public_subnet_id
}
##################################
# ALB Listener 생성
resource "aws_alb_listener" "ALB_listener" {
  load_balancer_arn = aws_alb.myALB.arn
  port = 80 
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.myTG.arn 
  }
}
####################################
# 시작 템플릿 생성
resource "aws_launch_template" "web_launch_template" {
  name = "web_launch_template"
  image_id = "ami-075e056c0f3d02523"
  instance_type = "t2.micro"
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    TOMCAT_DNS=var.was_dns
  }))
  iam_instance_profile {
    arn = var.iam_role_profile_arn
  }
  vpc_security_group_ids = [ var.vpc_security_group_id ]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-template"
    }
  }
}
#####################################
# AutoScalingGroup 생성 및 연결
resource "aws_autoscaling_group" "myASG" {
  name = "webasg"
  min_size = 1
  max_size = 5
  desired_capacity = 1
  health_check_grace_period = 30
  health_check_type = "EC2"
  force_delete = false 
  vpc_zone_identifier = [ var.private_subnet_id[0], var.private_subnet_id[1] ]
  launch_template {
    id = aws_launch_template.web_launch_template.id 
    version = "$Latest"
  }
}
resource "aws_autoscaling_attachment" "myASG_attachment" {
  autoscaling_group_name = aws_autoscaling_group.myASG.id 
  lb_target_group_arn = aws_alb_target_group.myTG.arn 
}
