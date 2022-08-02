# ------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7"
    }
  }
}