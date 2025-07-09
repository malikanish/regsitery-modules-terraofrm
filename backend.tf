terraform {
  backend "s3" {
    bucket         = "anish-state-bucket-12345"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
