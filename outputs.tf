output "aws_region" {
  description = "AWS region in which to find the alarm."
  value       = var.aws_region
}

output "instance_id" {
  description = "Monitored EC2 instance ID."
  value       = aws_instance.monitor.id
}

output "alarm_name" {
  description = "CloudWatch alarm to open in the AWS console."
  value       = aws_cloudwatch_metric_alarm.cpu.alarm_name
}
