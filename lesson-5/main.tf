provider "aws" {
  region = "eu-west-1"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "my-lesson-5-bucket-${random_id.bucket_suffix.hex}"
  table_name  = "terraform-locks"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_name           = "lesson-5-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}
