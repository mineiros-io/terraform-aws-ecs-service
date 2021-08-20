# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ----------------------------------------------------------------------------------------------------------------------

output "ecs_service" {
  description = "All outputs of the \"aws_ecs_service\" resource."
  value       = try(aws_ecs_service.service[0], {})
}

output "ecs_task_definition" {
  description = "All outputs of the \"aws_ecs_service\" resource."
  value       = try(aws_ecs_task_definition.task[0], {})
}

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT MODULE CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether the module is enabled."
  value       = var.module_enabled
}

output "module_tags" {
  description = "A map of tags that will be applied to all created resources that accept tags."
  value       = var.module_tags
}
