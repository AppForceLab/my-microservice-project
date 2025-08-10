terraform {
  backend "s3" {
    bucket         = "my-lesson-7-bucket-52368628"
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
