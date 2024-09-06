output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.main.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.main.public_dns}"
}

output "app_version" {
  description = "Version of the application deployed"
  value       = var.app_version
}

output "deployment_timestamp" {
  description = "Timestamp of the latest deployment"
  value       = timestamp()
}