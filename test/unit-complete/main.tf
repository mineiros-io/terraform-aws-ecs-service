# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COMPLETE FEATURES UNIT TEST
# This module tests a complete set of most/all non-exclusive features
# The purpose is to activate everything the module offers, but trying to keep execution time and costs minimal.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "aws_region" {
  description = "(Optional) The AWS region in which all resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
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

resource "aws_ecs_cluster" "ecs" {
  name = "ecs-test-unit-complete"
}

# Define the Assume Role IAM Policy Document for the ECS Service Scheduler IAM Role
data "aws_iam_policy_document" "assume_service_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

module "task-role" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  module_enabled = var.module_enabled

  name               = "task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_service_role.json
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ECS TASK EXECUTION IAM ROLE
# The ECS task execution role enables the ECS agent and ECS container instance to communicate with other AWS services,
#  e.g:
# - Pulling a images from Amazon ECR
# - Using the awslogs log driver
# ---------------------------------------------------------------------------------------------------------------------

module "task-execution-role" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  module_enabled = var.module_enabled

  name               = "task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_service_role.json
}

module "task-execution-policy" {
  source  = "mineiros-io/iam-policy/aws"
  version = "~> 0.5.0"

  module_enabled = var.module_enabled

  name  = "task-execution-policy"
  roles = [module.task-execution-role.role.name]

  policy_statements = [
    {
      effect = "Allow"

      actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]

      # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/iam-identity-based-access-control-cwl.html
      resources = ["*"]
    },
    {
      effect = "Allow"

      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]

      resources = [
        "*",
      ]
    }
  ]
}

# DO NOT RENAME MODULE NAME
module "test" {
  source = "../.."

  module_enabled = var.module_enabled

  # add all required arguments
  name    = "ecs-service-test-unit-complete"
  cluster = aws_ecs_cluster.ecs.arn

  task_definition = {
    network_mode       = "awsvpc"
    execution_role_arn = module.task-execution-role.role.arn
    task_role_arn      = module.task-role.role.arn
    cpu                = 256
    memory             = 512

    container_definitions = jsonencode([{
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "tess/unit-complete"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }])
  }

  # add most/all optional arguments
  launch_type = "FARGATE"

  network_configuration = {
    subnets          = data.aws_subnet_ids.default.ids
    assign_public_ip = true
    security_groups  = [aws_default_security_group.default.id]
  }

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = 1
    },
  ]

  deployment_circuit_breaker = [
    {
      enable   = true,
      rollback = true
    }
  ]

  deployment_controller_type = "ECS"

  desired_count = 2

  enable_ecs_managed_tags = true
  enable_execute_command  = true
  force_new_deployment    = true

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "TASK_DEFINITION"

  service_tags = {
    Service = "Bob"
  }

  module_tags = {
    Environment = "unknown"
  }

  module_depends_on = ["nothing"]
}

# outputs generate non-idempotent terraform plans so we disable them for now unless we need them.
# output "all" {
#   description = "All outputs of the module."
#   value       = module.test
# }
