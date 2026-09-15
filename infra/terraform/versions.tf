terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "tmdb-data-platform-terraform-state"
    key          = "tmdb-data-platform/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}