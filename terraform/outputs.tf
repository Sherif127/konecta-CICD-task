output "public_ip" {
  description = "Public IP of created instance"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}