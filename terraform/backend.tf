terraform {
  backend "s3" {
    bucket         = "sherif-konecta-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}