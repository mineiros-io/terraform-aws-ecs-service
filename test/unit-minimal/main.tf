# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MINIMAL FEATURES UNIT TEST
# This module tests a minimal set of features.
# The purpose is to test all defaults for optional arguments and just provide the required arguments.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "aws_region" {
  description = "(Optional) The AWS region in which all resources will be created."
  type        = string
  default     = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # always test with exact version to catch unsupported blocks/arguments early
      # this should match the minimal version in versions.tf
      version = "3.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "test" {
  source = "../.."

  # add only required arguments and no optional arguments
}

output "all" {
  description = "All outputs of the module."
  value       = module.test
}
