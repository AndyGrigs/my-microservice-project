terraform {
  backend "s3" {
    bucket         = "django-terraform-state-bucket-2024"
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}