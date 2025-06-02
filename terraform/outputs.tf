output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

output "ecr_webapp_repository_url" {
  description = "ECR repository URL for the webapp image"
  value       = aws_ecr_repository.webapp.repository_url
}

output "ecr_mysql_repository_url" {
  description = "ECR repository URL for the MySQL image"
  value       = aws_ecr_repository.mysql.repository_url
}