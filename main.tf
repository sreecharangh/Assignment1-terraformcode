provider "aws" {
  region = "us-east-1"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"  
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "assignment1"  
}

variable "ec2_instances" {
  description = "List of EC2 instance names"
  type        = list(string)
  default     = ["red", "green", "blue"]
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
  default     = "sg-08ba0abbbd57ef070"  
}

resource "aws_instance" "ec2_instances" {
  count         = length(var.ec2_instances)
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name = var.ec2_instances[count.index]
  }
}

resource "aws_lb" "rbg" {
  name               = "RBG Load Balancer"
  internal           = false
  load_balancer_type = "application"

  subnets = ["subnet-12345678", "subnet-23456789"]  # Replace with your desired subnet IDs

  security_groups = [var.security_group_id]

  tags = {
    Name = "RBG Load Balancer"
  }
}

resource "aws_lb_target_group" "rbg" {
  name     = "rbg-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-12345678"  # Replace with your desired VPC ID
}

resource "aws_lb_listener" "rbg" {
  load_balancer_arn = aws_lb.rbg.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rbg.arn
  }
}

resource "aws_lb_listener_rule" "red_rule" {
  listener_arn = aws_lb_listener.rbg.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rbg.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/red"]
  }
}

resource "aws_lb_listener_rule" "green_rule" {
  listener_arn = aws_lb_listener.rbg.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rbg.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/green"]
  }
}

resource "aws_lb_listener_rule" "blue_rule" {
  listener_arn = aws_lb_listener.rbg.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rbg.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/blue"]
  }
}

resource "aws_lb_target_group_attachment" "ec2_instances" {
  count             = length(var.ec2_instances)
  target_group_arn  = aws_lb_target_group.rbg.arn
  target_id         = aws_instance.ec2_instances[count.index].id
  port              = 80
}

resource "assignment1" "ecr1" {
  name = "ecr1"
}

depends_on = [
  aws_lb_listener.rbg,
  aws_lb_target_group.rbg,
  aws_ecr_repository.ecr,
]
