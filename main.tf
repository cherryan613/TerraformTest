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

# SSH 키 생성
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# AWS 키 페어 생성
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key"
  public_key = tls_private_key.example.public_key_openssh
}

# EC2 인스턴스 생성
resource "aws_instance" "web_server" {
  ami             = "ami-062cddb9d94dcf95d"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ec2_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  # 인스턴스 시작 시 Nginx 설치
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = {
    Name        = "web-server"
    Environment = var.environment
  }
}