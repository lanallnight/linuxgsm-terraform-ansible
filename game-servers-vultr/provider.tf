terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 1.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.19.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "onepassword" {
  service_account_token = var.onepassword_token # "<1Password service account token>"
}

provider "tls" {
  # Configuration options
}

provider "vultr" {
  api_key     = var.vultr_token
  rate_limit  = 100
  retry_limit = 3
}

provider "aws" {
  region = "us-west-2"
}

variable "onepassword_token" {}
variable "linode_token" {}
variable "vultr_token" {}
