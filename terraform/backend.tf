terraform {
  backend "s3" {
    bucket         = "chris-terraform-minecraft-bucket"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}