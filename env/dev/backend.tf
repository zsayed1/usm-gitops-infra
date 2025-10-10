terraform {
  backend "s3" {
    bucket         = "usm-terraform-state-bucket"
    key            = "eks-platform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
