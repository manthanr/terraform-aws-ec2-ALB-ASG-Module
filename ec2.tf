#Find AWS AMI if user does not specify one

data "aws_ami" "linux" {

    most_recent = true

    owners = ["amazon"] # Canonical

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*-gp2"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

}

#Create Launch Configuration for Auto Scaling Group

resource "aws_launch_configuration" "ec2-launch-config" {
  name          = "Terraform_Webserver_Module"
  image_id      =  var.ec2_ami == "amazon-linux-2" ? data.aws_ami.linux.id : var.ec2_ami  
  instance_type = var.ec2_type
  key_name = var.keypair == "none" ? null : var.keypair
  user_data = var.user_data == "none" ? null : file("${path.module}/${var.user_data}")
  security_groups = var.ec2_security_groups
  lifecycle {
    create_before_destroy = true
  }
}

#Create Auto Scaling Policy

resource "aws_autoscaling_policy" "EC2-Scaling" {
  name = var.ec2_scaling_policy_group_name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.scalingtreshold
  }
  autoscaling_group_name = aws_autoscaling_group.EC2-Scaling-Group.id
  
}


#Create Auto Scaling Group

resource "aws_autoscaling_group" "EC2-Scaling-Group" {
  name                      = var.ec2_scaling_policy_group_name
  max_size                  = var.max_instances
  min_size                  = var.min_instances
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = var.ec2_subnet_ids
  launch_configuration = aws_launch_configuration.ec2-launch-config.id
  target_group_arns = [aws_lb_target_group.WebServer_TargetGroup.arn]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  timeouts {
    delete = "15m"
  }
  tag {
    key                 = var.tag.key
    value               = var.tag.value
    propagate_at_launch = var.tag.propagate_at_launch
  }

  lifecycle {
    create_before_destroy = false
  }

}


#Create Application Load Balancer in Specified Subnets
resource "aws_lb" "WebServerLoadBalancer" {
  count = var.launchlb ? 1 : 0
  internal           = var.lb_internal
  enable_cross_zone_load_balancing   = true
  load_balancer_type = "application"
  security_groups    = var.lb_security_groups
  subnets            = var.lb_subnet_ids
  tags = {
        Name = "${var.tag.value}-ALB"
    }
}


#Create Listener on Application Load Balancer to forward to Target Group
resource "aws_lb_listener" "front_end_listener" {
  count = var.launchlb ? 1 : 0
  load_balancer_arn = aws_lb.WebServerLoadBalancer[0].arn
  port              = var.lb_HTTPS ? "443" : "80"
  protocol          = var.lb_HTTPS ? "HTTPS" : "HTTP"
  certificate_arn =  var.lb_HTTPS ? var.ACN_ARN : null
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.WebServer_TargetGroup.arn
  }
}

#If HTTPS, create HTTP -> HTTPS Re-Direct Listener on Application Load Balancer
resource "aws_lb_listener" "front_end_listener_HTTPtoHTTPSredirect" {
  count = var.lb_HTTPS ? 1 : 0
  load_balancer_arn = aws_lb.WebServerLoadBalancer[0].arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


#Create ALB Target Group for Auto-Scaling Group
resource "aws_lb_target_group" "WebServer_TargetGroup" {
  port     = var.target_HTTPS ? "443" : "80"
  vpc_id = var.targetgroup_vpc
  protocol = var.target_HTTPS ? "HTTPS" : "HTTP"
  tags = {
        Name = "${var.tag.value}-ALBTargetGroup"
  }
}

