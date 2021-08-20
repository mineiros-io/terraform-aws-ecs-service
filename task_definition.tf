resource "aws_ecs_task_definition" "task" {
  count = var.module_enabled ? 1 : 0

  family                = try(var.task_definition.family, var.name)
  container_definitions = var.task_definition.container_definitions
  task_role_arn         = try(var.task_definition.task_role_arn, null)
  execution_role_arn    = try(var.task_definition.execution_role_arn, null)
  network_mode          = try(var.task_definition.network_mode, "bridge")

  # For FARGATE, compatibility, CPU and memory need to be defined
  # in the task definition instead of in the container definition
  requires_compatibilities = local.is_fargate ? ["FARGATE"] : null
  cpu                      = try(var.task_definition.cpu, null)
  memory                   = try(var.task_definition.memory, null)

  tags = merge(var.module_tags, try(var.task_definition.tags, {}))

  depends_on = [var.module_depends_on]
}
