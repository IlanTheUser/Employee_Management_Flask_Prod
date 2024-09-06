output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "app_version" {
  description = "Version of the application deployed"
  value       = var.app_version
}

output "deployment_timestamp" {
  description = "Timestamp of the latest deployment"
  value       = timestamp()
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "ami_id" {
  description = "ID of the AMI used for EC2 instances"
  value       = var.ami_id
}

output "instance_type" {
  description = "Type of EC2 instances"
  value       = var.instance_type
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}