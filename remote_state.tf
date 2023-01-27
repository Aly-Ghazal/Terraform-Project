resource "aws_s3_bucket" "Terraform_state" {
  bucket = "aly-ghazal-terraform-up-and-running"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.Terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "aly-ghazal-terraform-up-and-running"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}