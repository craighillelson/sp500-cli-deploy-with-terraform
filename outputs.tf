output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.sp500_app.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.sp500_app.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.sp500_app.public_dns
}
