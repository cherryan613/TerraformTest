provider "aws" {
  region = var.aws_region
  
  # GitHub Actions에서는 아래 설정은 필요 없고, 환경변수로 설정합니다
  # profile = var.terraform_aws_profile
  # access_key = var.aws_access_key_id
  # secret_key = var.aws_secret_access_key
  
  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}