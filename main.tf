# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE AN ELASTIC CONTAINER SERVICE
# This module creates a service on Amazon Elastic Container Service (Amazon ECS).
# - main.tf: All resources for the ECS service
# - task_definition.tf: All resources for the ECS service task definition 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

locals {
  launch_type = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  # Filter FARGATE and FARGATE_SPOT capacity providers based on their restricted names
  has_fargate_capacity_providers = anytrue([
    for provider in var.capacity_provider_strategy :
    can(regex("^(FARGATE|FARGATE_SPOT)$", provider.capacity_provider))
  ])

  is_fargate = local.launch_type == "FARGATE" || local.has_fargate_capacity_providers
}

resource "aws_ecs_service" "service" {
  count = var.module_enabled ? 1 : 0

  name             = var.name
  cluster          = var.cluster
  launch_type      = local.launch_type
  desired_count    = var.desired_count
  platform_version = var.launch_type == "FARGATE" ? var.platform_version : null
  task_definition  = aws_ecs_task_definition.task[0].arn

  iam_role = var.iam_role_arn

  scheduling_strategy                = var.scheduling_strategy
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_execute_command            = var.enable_execute_command
  wait_for_steady_state             = var.wait_for_steady_state
  force_new_deployment              = var.force_new_deployment

  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  propagate_tags          = var.propagate_tags

  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []

    content {
      subnets          = network_configuration.value.subnets
      security_groups  = try(network_configuration.value.security_groups, null)
      assign_public_ip = try(network_configuration.value.assign_public_ip, false)
    }
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker

    content {
      enable   = try(deployment_circuit_breaker.value.enable, true)
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = try(capacity_provider_strategy.value.base, null)
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      type  = ordered_placement_strategy.value.type
      field = try(ordered_placement_strategy.value.field, null)
    }
  }

  dynamic "placement_constraints" {
    for_each = local.is_fargate ? [] : var.placement_constraints

    content {
      type       = placement_constraints.value.type
      expression = try(placement_constraints.value.expression, null)
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers

    content {
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries

    content {
      registry_arn   = service_registries.value.registry_arn
      port           = try(service_registries.value.port, null)
      container_port = try(service_registries.value.container_port, null)
      container_name = try(service_registries.value.container_name, null)
    }
  }

  tags = merge(var.module_tags, var.service_tags)

  depends_on = [var.module_depends_on]
}
