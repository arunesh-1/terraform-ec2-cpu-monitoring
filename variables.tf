variable "aws_region" {
  description = "AWS region for the instance and alarm."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type supporting x86_64."
  type        = string
  default     = "t3.micro"
}
