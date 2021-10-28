# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ----------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "(Required) Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string

  # validation {
  #   condition     = length(var.name) <= 255 && can()
  #   error_message = "Name of the service should have a length of max 255 chars and may contain numbers, hyphens, and underscores."
  # }
}

variable "cluster" {
  description = "(Required) The Amazon Resource Name (ARN) of the ECS Cluster where this service should run."
  type        = string
}


variable "task_definition" {
  description = "(Required) Task definition configuration of the service."
  # type = object({
  #   # (Optional) A unique name for your task definition. If omitted, the name of the service will be used.
  #   family = optional(string)
  #   # "(Required) The JSON text of the ECS Task Container Definitions. This portion of the ECS Task Definition defines the Docker container(s) to be run along with all their properties. For details and format please see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html#task-definition-template"
  #   container_definitions = string
  #   # (Required) The ARN of the IAM role that grants your Amazon ECS container task the permission to communicate with other AWS services
  #   task_role_arn = string
  #   # (Optional) ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
  #   task_execution_role_arn = optional(string)
  #   # (Optional) The Docker networking mode to use for the containers in the task. The valid values are \"none\", \"bridge\", \"awsvpc\", and \"host\".
  #   network_mode = optional(string)
  #   # (Optional) The CPU units for the instances that Fargate will spin up. Options here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size. Required when using FARGATE launch type.
  #   cpu = optional(number)
  #   # (Optional) The memory units for the instances that Fargate will spin up. Options here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size. Required when using FARGATE launch type.
  #   memory = optional(number)
  #   # (Optional) A map of tags to apply to the task definition. Each item in this list should be a map with the parameters key and value.
  #   tags = optional(map(string))
  # })
  type = any
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ----------------------------------------------------------------------------------------------------------------------

# Service configuration

variable "launch_type" {
  description = "(Optional) Launch type that will be used to run your service. The valid values are \"EC2\", \"FARGATE\", and \"EXTERNAL\"."
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "FARGATE", "EXTERNAL"], upper(var.launch_type))
    error_message = "The valid values for 'var.launch_type' are 'EC2', 'FARGATE', and 'EXTERNAL'."
  }
}

variable "network_configuration" {
  description = "(Optional) Network configuration for the service. This parameter is required for task definitions that use the \"awsvpc\" network mode to receive their own Elastic Network Interface (ENI), and it is not supported for other network modes."
  type        = any
  # type = object({
  #   subnets          = list(string)
  #   security_groups  = optional(list(string))
  #   assign_public_ip = optional(bool)
  # })
  default = null
}

variable "capacity_provider_strategy" {
  description = "(Optional) Capacity provider strategies to use for the service."
  type        = any
  # type = list(object({
  #   capacity_provider = string
  #   weight            = number
  #   base              = optional(number)
  # }))
  default = []

  # Example:
  # capacity_provider_strategy = [
  #    {
  #      capacity_provider = "FARGATE"
  #      weight            = 1
  #      base              = 2
  #    },
  #    {
  #      capacity_provider = "FARGATE_SPOT"
  #      weight            = 2
  #      base              = null
  #    },
  # ]
}

variable "deployment_circuit_breaker" {
  description = "(Optional) Configuration block for deployment circuit breaker."
  type        = any
  # type = list(object({
  #   enable   = bool
  #   rollback = bool
  # }))
  default = []
}

variable "deployment_controller_type" {
  description = "(Optional) The type of the deployment controller. Valid values: \"CODE_DEPLOY\", \"ECS\", \"EXTERNAL\"."
  type        = string
  default     = "ECS"
}

variable "deployment_maximum_percent" {
  description = "(Optional) The upper limit (as a percentage of \"var.desired_count\") of the number of running tasks that can be running in a service during a deployment. Not valid when using the \"DAEMON\" scheduling strategy. If settings this to more than \"100\" means that during a deployment, ECS will deploy new instances of a task before undeploying the old ones."
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "(Optional) The lower limit (as a percentage of var.desired_count) of the number of running tasks that must remain running and healthy in a service during a deployment. Setting this to less than 100 means that during a deployment, ECS may undeploy old instances of a Task before deploying new ones."
  type        = number
  default     = 100
}

variable "desired_count" {
  description = "(Optional) Number of instances of the task definition to place and keep running. Do not specify if using the \"DAEMON\" scheduling strategy."
  type        = number
  default     = 0
}

variable "enable_ecs_managed_tags" {
  description = "(Optional) Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "(Optional) Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g. \"myimage:latest\"), roll Fargate tasks onto a newer platform version, or immediately deploy \"ordered_placement_strategy\" and \"placement_constraints updates\"."
  type        = bool
  default     = false
}

variable "wait_for_steady_state" {
  description = "(Optional) If true, Terraform will wait for the service to reach a steady state—as in, the ECS tasks you wanted are actually deployed—before \"apply\" is considered complete."
  type        = bool
  default     = false
}

# Placement strategy configuration

variable "ordered_placement_strategy" {
  description = "(Optional) Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. Updates to this configuration will take effect next task deployment unless force_new_deployment is enabled. The maximum number of \"ordered_placement_strategy\" blocks is \"5\". For details please see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#ordered_placement_strategy"
  type        = any
  # type = list(object({
  #   type  = string
  #   field = optional(string)
  # }))
  default = []

  validation {
    condition     = length(var.ordered_placement_strategy) <= 5
    error_message = "The maximum number of 'ordered_placement_strategy' blocks is 5."
  }
}

variable "placement_constraints" {
  description = "(Optional) Rules that are taken into consideration during task placement. Updates to this configuration will take effect next task deployment unless \"force_new_deployment\" is enabled. Maximum number of \"placement_constraints\" is \"10\"."
  type        = any
  # type = list(object({
  #   type       = string
  #   expression = optional(string)
  # }))
  default = []
}

# LoadBalancer health check configuration

variable "load_balancers" {
  description = "(Optional) Configuration block for one or more load balancers."
  type        = any
  # type = list(object({
  #   elb_name         = optional(string)
  #   target_group_arn = string
  #   container_name   = string
  #   container_port   = number
  # }))
  default = []
}

variable "health_check_grace_period_seconds" {
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to \"2,147,483,647\". Only valid for services configured to use load balancers."
  type        = number
  default     = 0
}

variable "iam_role_arn" {
  description = "(Optional) ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the \"awsvpc\" network mode. If using \"awsvpc\" network mode, do not specify this role. If your account has already created the Amazon ECS service-linked role, that role is used by default for your service unless you specify a role here."
  type        = string
  default     = null
}

variable "platform_version" {
  description = "(Optional) The platform version on which to run your service. Only applicable for \"launch_type\" set to \"FARGATE\". Defaults to \"LATEST\"."
  type        = string
  default     = "LATEST"
}

variable "scheduling_strategy" {
  description = "(Optional) Scheduling strategy to use for the service. The valid values are \"REPLICA\" and \"DAEMON\".  Note that Tasks using the Fargate launch type or the \"CODE_DEPLOY\" or \"EXTERNAL\" deployment controller types don't support the \"DAEMON\" scheduling strategy."
  type        = string
  default     = "REPLICA"

  validation {
    condition     = contains(["REPLICA", "DAEMON"], upper(var.scheduling_strategy))
    error_message = "The valid values for 'var.scheduling_strategy' are 'REPLICA' and 'DAEMON'."
  }
}

variable "propagate_tags" {
  description = "(Optional) Whether tags should be propogated to the tasks from the service or from the task definition. Valid values are \"SERVICE\" and \"TASK_DEFINITION\". Defaults to \"SERVICE\". If set to null, no tags are created for tasks."
  type        = string
  default     = "SERVICE"

  validation {
    condition     = var.propagate_tags == null || contains(["SERVICE", "TASK_DEFINITION"], upper(var.propagate_tags))
    error_message = "The valid values for 'var.propagate_tags' are 'SERVICE' and 'TASK_DEFINITION'."
  }

}

variable "service_tags" {
  description = "(Optional) A map of tags to apply to the ECS service. Each item in this list should be a map with the parameters key and value."
  type        = map(string)
  default     = {}
  # Example:
  #   {
  #     key1 = "value1"
  #     key2 = "value2"
  #   }
}

variable "service_registries" {
  description = "(Optional)"
  # type = list(object({
  #   registry_arn   = string
  #   port           = optional(number)
  #   container_port = optional(number)
  #   container_name = optional(string)
  # }))
  type    = any
  default = []
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# ----------------------------------------------------------------------------------------------------------------------

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

variable "module_tags" {
  type        = map(string)
  description = "(Optional) A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be overwritten by resource-specific tags."
  default     = {}
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}
