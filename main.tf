provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# 보안 그룹 설정
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  description = "Security group for web server"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH 키 생성 (private/public 키 페어)
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# AWS에 public key 등록
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key-${substr(uuid(), 0, 8)}"
  public_key = tls_private_key.example.public_key_openssh
}

# .pem 파일을 로컬에 저장
resource "local_file" "private_key_pem" {
  content              = tls_private_key.example.private_key_pem
  filename             = "${path.module}/ec2-key.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

# EC2 인스턴스 생성
resource "aws_instance" "web_server" {
  ami                         = "ami-062cddb9d94dcf95d" # Amazon Linux 2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2_key.key_name
  security_groups             = [aws_security_group.web_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = {
    Name        = "web-server"
    Environment = "dev"
  }

  depends_on = [local_file.private_key_pem]
}

# 출력: 퍼블릭 IP 주소
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}
