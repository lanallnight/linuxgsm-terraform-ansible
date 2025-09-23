terraform {
  backend "s3" {
    key            = "terraform/game-servers-vultr.tfstate"
    bucket         = "terraform-state-lan"
    dynamodb_table = "terraform-state-lan"
    encrypt        = true
    region         = "us-west-2"
    profile        = "default"
  }
}
