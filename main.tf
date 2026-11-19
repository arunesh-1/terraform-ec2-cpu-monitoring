terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_vpc" "monitor" {
  cidr_block = "10.1.0.0/16"

  tags = { Name = "terraform-cpu-monitor-vpc" }
}

resource "aws_subnet" "monitor" {
  vpc_id     = aws_vpc.monitor.id
  cidr_block = "10.1.1.0/24"

  tags = { Name = "terraform-cpu-monitor-subnet" }
}

resource "aws_security_group" "monitor" {
  name        = "terraform-cpu-monitor-isolated"
  description = "No inbound or outbound access"
  vpc_id      = aws_vpc.monitor.id

  tags = { Name = "terraform-cpu-monitor-isolated" }
}

resource "aws_instance" "monitor" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.monitor.id
  vpc_security_group_ids      = [aws_security_group.monitor.id]
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = { Name = "terraform-cpu-monitor" }
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "terraform-ec2-cpu-${aws_instance.monitor.id}"
  alarm_description   = "CPU utilization above 70% for two consecutive minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.monitor.id
  }
}
