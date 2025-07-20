terraform {
  backend "s3" {
    bucket         = "my-lesson-5-bucket-e0f05b06"
    key            = "lesson-5/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
