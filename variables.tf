variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"  # 서울 리전
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "my-vpc"
}

variable "environment" {
  description = "Environment name (e.g., dev, stg, prd)"
  type        = string
  default     = "dev"
}