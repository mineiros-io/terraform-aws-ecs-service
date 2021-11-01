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
      version = "3.50.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "cluster_name" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_ecs_cluster" "ecs" {
  name = random_string.cluster_name.result
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_default_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

# DO NOT RENAME MODULE NAME
module "test" {
  source = "../.."

  # add only required arguments and no optional arguments
  name    = random_string.cluster_name.result
  cluster = aws_ecs_cluster.ecs.arn
  task_definition = {
    network_mode = "awsvpc"
    cpu          = 256
    memory       = 512

    container_definitions = jsonencode([{
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
    }])
  }

  # add most/all optional arguments
  launch_type = "FARGATE"

  network_configuration = {
    subnets          = data.aws_subnet_ids.default.ids
    assign_public_ip = true
    security_groups  = [aws_default_security_group.default.id]
  }
}

# outputs generate non-idempotent terraform plans so we disable them for now unless we need them.
# output "all" {
#   description = "All outputs of the module."
#   value       = module.test
# }
