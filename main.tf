terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Get your current public IP
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

provider "aws" {
  region = var.aws_region
}

# Security group for the EC2 instance
resource "aws_security_group" "sp500_sg" {
  name        = "sp500-cli-sg"
  description = "Security group for S&P 500 CLI application"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip] # restricts to your IP
  }

  # HTTP access (if running Flask web server)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sp500-cli-sg"
  }
}

# EC2 instance
resource "aws_instance" "sp500_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.sp500_sg.id]

  user_data = file("user-data.sh")

  tags = {
    Name = "sp500-cli-app"
  }
}

# SNS topic for alarm notifications (optional but recommended)
resource "aws_sns_topic" "sp500_alarms" {
  name = "sp500-alarms"
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.sp500_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email # Add this variable
}

# CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "sp500-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 80 # Alert if CPU > 80%
  alarm_description   = "Alert when CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.sp500_alarms.arn]

  dimensions = {
    InstanceId = aws_instance.sp500_app.id
  }
}