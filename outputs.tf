# EC2 인스턴스의 퍼블릭 IP 출력
output "web_instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the web server"
}

# SSH 연결을 위한 프라이빗 키 출력
output "ssh_private_key_pem" {
  value       = tls_private_key.example.private_key_pem
  description = "Private key for SSH access"
  sensitive   = true
}