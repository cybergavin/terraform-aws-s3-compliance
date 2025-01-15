terraform {
  required_version = "~> 1.0, >= 1.8" # Ensure compatibility with OpenTofu 1.8.x
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Allow updates within the 5.x series
    }
  }
}