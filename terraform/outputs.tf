output "EC2_Public_IP" {
  description = "Public IP of the backend EC2 instance"
  value       = aws_instance.web.public_ip
}

resource "local_file" "ansible_inventory_file_creation" {
  content = <<-EOT
    [all:vars]
    ansible_user=ec2-user
    ansible_ssh_private_key_file=~/.ssh/mykeypair.pem

    [backend]
    backend-ec2 ansible_host=${aws_instance.web.public_ip}
  EOT

  filename = "${path.module}/../ansible/inventory.ini"
}