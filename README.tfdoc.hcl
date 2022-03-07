header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-aws-ecs-service"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-aws-ecs-service/workflows/Tests/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-aws-ecs-service/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-ecs-service.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-aws-ecs-service/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-aws-provider" {
    image = "https://img.shields.io/badge/AWS-3.5-F8991D.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-aws/releases"
    text  = "AWS Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-aws-ecs-service"
  toc     = true
  content = <<-END
    A [Terraform] module to create and manage
    [Amazon ECS Services](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html)
    on [Amazon Web Services (AWS)][aws].

    **_This module supports Terraform version 1
    and is compatible with the Terraform AWS Provider version 3.5 to 4.0**

    This module is part of our Infrastructure as Code (IaC) framework
    that enables our users and customers to easily deploy and manage reusable,
    secure, and production-grade cloud infrastructure.
  END

  section {
    title   = "Module Features"
    content = <<-END
      This module implements the following Terraform resources

      - `aws_ecs_service`
      - `aws_ecs_task_definition`
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most common usage of the module:

      ```hcl
      module "terraform-aws-ecs-service" {
        source = "git@github.com:mineiros-io/terraform-aws-ecs-service.git?ref=v0.0.1"

        name   = "name-of-service"
        cluser = "name-of-cluster"

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
      }
      ```
    END
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Main Resource Configuration"

      variable "name" {
        required    = true
        type        = string
        description = <<-END
          Name of the service (up to 255 letters, numbers, hyphens, and
          underscores).
        END
      }

      variable "cluster" {
        required    = true
        type        = string
        description = <<-END
          The Amazon Resource Name (ARN) of the ECS Cluster where this service
          should run.
        END
      }

      variable "launch_type" {
        type        = string
        default     = "EC2"
        description = <<-END
          Launch type that will be used to run your service. The valid values
          are `EC2`, `FARGATE`, and `EXTERNAL`.
        END
      }

      variable "network_configuration" {
        type        = object(network_configuration)
        description = <<-END
          Network configuration for the service. This parameter is required for
          task definitions that use the awsvpc network mode to receive their
          own Elastic Network Interface, and it is not supported for other
          network modes.
        END

        attribute "subnets" {
          required    = true
          type        = set(string)
          description = <<-END
            Subnets associated with the task or service.
          END
        }

        attribute "security_groups" {
          type        = set(string)
          description = <<-END
            Security groups associated with the task or service. If you do not
            specify a security group, the default security group for the VPC is
            used.
          END
        }

        attribute "assign_public_ip" {
          type        = bool
          description = <<-END
            Assign a public IP address to the ENI (Fargate launch type only).
            Valid values are `true` or `false`.
          END
        }
      }

      variable "capacity_provider_strategy" {
        type        = set(capacity_provider_strategy)
        default     = []
        description = <<-END
          Capacity provider strategies to use for the service. Can be one or
          more. These can be updated without destroying and recreating the
          service only if `force_new_deployment = true` and not changing from
          0 `capacity_provider_strategy` blocks to greater than 0, or vice versa.
        END

        attribute "capacity_provider" {
          required    = true
          type        = string
          description = <<-END
            Short name of the capacity provider.
          END
        }

        attribute "weight" {
          required    = true
          type        = number
          description = <<-END
            Relative percentage of the total number of launched tasks that
            should use the specified capacity provider.
          END
        }

        attribute "base" {
          type        = number
          description = <<-END
            Number of tasks, at a minimum, to run on the specified capacity
            provider. Only one capacity provider in a capacity provider strategy
            can have a base defined.
          END
        }
      }

      variable "deployment_circuit_breaker" {
        type        = list(deployment_circuit_breaker)
        default     = []
        description = <<-END
          Configuration block for deployment circuit breaker.
        END

        attribute "enable" {
          type        = bool
          default     = true
          description = <<-END
            Whether to enable the deployment circuit breaker logic for the
            service.
          END
        }

        attribute "rollback" {
          required    = true
          type        = bool
          description = <<-END
            Whether to enable Amazon ECS to roll back the service if a service
            deployment fails. If rollback is enabled, when a service deployment
            fails, the service is rolled back to the last deployment that
            completed successfully.
          END
        }
      }

      variable "deployment_controller_type" {
        type        = string
        default     = "ECS"
        description = <<-END
          The type of the deployment controller. Valid values: `CODE_DEPLOY`,
          `ECS`, `EXTERNAL`.
        END
      }

      variable "deployment_maximum_percent" {
        type        = number
        default     = 200
        description = <<-END
          The upper limit (as a percentage of `var.desired_count`) of the
          number of running tasks that can be running in a service during a
          deployment. Not valid when using the `DAEMON` scheduling strategy.
          If settings this to more than `100` means that during a deployment,
          ECS will deploy new instances of a task before undeploying the old
          ones.
        END
      }

      variable "deployment_minimum_healthy_percent" {
        type        = number
        default     = 100
        description = <<-END
          The lower limit (as a percentage of `desired_count`) of the number of
          running tasks that must remain running and healthy in a service during
          a deployment. Setting this to less than 100 means that during a
          deployment, ECS may undeploy old instances of a Task before deploying
          new ones.
        END
      }

      variable "desired_count" {
        type        = number
        default     = 0
        description = <<-END
          Number of instances of the task definition to place and keep running.
          Do not specify if using the `DAEMON` scheduling strategy.
        END
      }

      variable "enable_ecs_managed_tags" {
        type        = bool
        default     = false
        description = <<-END
          Specifies whether to enable Amazon ECS managed tags for the tasks
          within the service.
        END
      }

      variable "enable_execute_command" {
        type        = bool
        default     = false
        description = <<-END
          Specifies whether to enable Amazon ECS Exec for the tasks within the
          service.
        END
      }

      variable "force_new_deployment" {
        type        = bool
        default     = false
        description = <<-END
          Enable to force a new task deployment of the service. This can be used
          to update tasks to use a newer Docker image with same image/tag
          combination (e.g. `myimage:latest`), roll Fargate tasks onto a newer
          platform version, or immediately deploy `ordered_placement_strategy`
          and `placement_constraints updates`.
        END
      }

      variable "wait_for_steady_state" {
        type        = bool
        default     = false
        description = <<-END
          If `true`, Terraform will wait for the service to reach a steady
          state—as in, the ECS tasks you wanted are actually deployed—before
          `apply` is considered complete.
        END
      }

      variable "ordered_placement_strategy" {
        type        = list(ordered_placement_strategy)
        default     = []
        description = <<-END
          Service level strategy rules that are taken into consideration during
          task placement. List from top to bottom in order of precedence.
          Updates to this configuration will take effect next task deployment
          unless `force_new_deployment` is enabled. The maximum number of
          `ordered_placement_strategy` blocks is `5`. For details please
          see [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#ordered_placement_strategy).
        END

        attribute "type" {
          required    = true
          type        = string
          description = <<-END
            Type of placement strategy. Must be one of: `binpack`, `random`, or
            `spread`.
          END
        }

        attribute "field" {
          type        = string
          description = <<-END
            For the `spread` placement strategy, valid values are `instanceId` (or
            `host`, which has the same effect), or any platform or custom
            attribute that is applied to a container instance. For the `binpack`
            type, valid values are `memory` and `cpu`. For the `random` type, this
            attribute is not needed. For more information, see
            [Placement Strategy](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PlacementStrategy.html).
          END
        }
      }

      variable "placement_constraints" {
        type        = set(placement_constraint)
        default     = []
        description = <<-END
          Rules that are taken into consideration during task placement. Updates
          to this configuration will take effect next task deployment unless
          `force_new_deployment` is enabled. Maximum number of
          `placement_constraints` is `10`.
        END

        attribute "type" {
          required    = true
          type        = string
          description = <<-END
            Type of constraint. The only valid values at this time are
            `memberOf` and `distinctInstance`.
          END
        }

        attribute "expression" {
          type        = string
          description = <<-END
            Cluster Query Language expression to apply to the constraint. Does
            not need to be specified for the `distinctInstance` type. For more
            information, see [Cluster Query Language](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-query-language.html)
            in the Amazon EC2 Container Service Developer Guide.
          END
        }
      }

      variable "load_balancers" {
        type        = set(load_balancer)
        description = <<-END
          Configuration block for load balancers.
        END

        attribute "elb_name" {
          type        = string
          description = <<-END
            Name of the ELB (Classic) to associate with the service.
          END
        }

        attribute "target_group_arn" {
          type        = string
          description = <<-END
            ARN of the Load Balancer target group to associate with the service.
          END
        }

        attribute "container_name" {
          required    = true
          type        = string
          description = <<-END
            Name of the container to associate with the load balancer (as it
            appears in a container definition).
          END
        }

        attribute "container_port" {
          required    = true
          type        = number
          description = <<-END
            Port on the container to associate with the load balancer.
          END
        }
      }

      variable "health_check_grace_period_seconds" {
        type        = number
        default     = 0
        description = <<-END
          Seconds to ignore failing load balancer health checks on newly
          instantiated tasks to prevent premature shutdown, up to
          `2,147,483,647`. Only valid for services configured to use load
          balancers.
        END
      }

      variable "iam_role_arn" {
        type        = string
        description = <<-END
          ARN of the IAM role that allows Amazon ECS to make calls to your load
          balancer on your behalf. This parameter is required if you are using
          a load balancer with your service, but only if your task definition
          does not use the `awsvpc` network mode. If using `awsvpc` network
          mode, do not specify this role. If your account has already created
          the Amazon ECS service-linked role, that role is used by default for
          your service unless you specify a role here.
        END
      }

      variable "platform_version" {
        type        = string
        default     = "LATEST"
        description = <<-END
          The platform version on which to run your service. Only applicable for
          `launch_type` set to `FARGATE`. Defaults to `LATEST`.
        END
      }

      variable "scheduling_strategy" {
        type        = string
        default     = "REPLICA"
        description = <<-END
          Scheduling strategy to use for the service. The valid values are
          `REPLICA` and `DAEMON`.  Note that Tasks using the Fargate launch
          type or the `CODE_DEPLOY` or `EXTERNAL` deployment controller
          types don't support the `DAEMON` scheduling strategy.
        END
      }

      variable "propagate_tags" {
        type        = string
        default     = "SERVICE"
        description = <<-END
          Whether tags should be propogated to the tasks from the service or
          from the task definition. Valid values are `SERVICE` and
          `TASK_DEFINITION`. Defaults to `SERVICE`. If set to null, no tags
          are created for tasks.
        END
      }

      variable "service_tags" {
        type        = map(string)
        default     = {}
        description = <<-END
          A map of tags to apply to the ECS service. Each item in this list
          should be a map with the parameters key and value.
        END
      }

      variable "service_registries" {
        type        = list(service_registry)
        default     = []
        description = <<-END
          Service discovery registries for the service. The maximum number of
          `service_registries` blocks is `1`.
        END

        attribute "registry_arn" {
          required    = true
          type        = string
          description = <<-END
            ARN of the Service Registry. The currently supported service
            registry is Amazon Route 53 Auto Naming
            Service(`aws_service_discovery_service`). For more information,
            see [Service](https://docs.aws.amazon.com/Route53/latest/APIReference/Welcome.html).
          END
        }

        attribute "port" {
          type        = number
          description = <<-END
            Port value used if your Service Discovery service specified a
            SRV record.
          END
        }

        attribute "container_port" {
          type        = number
          description = <<-END
            Port value, already specified in the task definition, to be used
            for your service discovery service.
          END
        }

        attribute "container_name" {
          type        = string
          description = <<-END
            Container name value, already specified in the task definition, to
            be used for your service discovery service.
          END
        }
      }
    }

    section {
      title = "Extended Resource Configuration"

      variable "task_definition" {
        required    = true
        type        = object(task_definition)
        description = <<-END
          Task definition configuration of the service.
        END

        attribute "family" {
          type        = string
          default     = var.name
          description = <<-END
            A unique name for your task definition.
          END
        }

        attribute "container_definitions" {
          required    = true
          type        = string
          description = <<-END
            A list of valid [container definitions](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html)
            provided as a single valid JSON document. Please note that you
            should only provide values that are part of the container definition
            document. For a detailed description of what parameters are
            available, see the [Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
            section from the official
            [Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html).
          END
        }

        attribute "task_role_arn" {
          type        = string
          description = <<-END
            ARN of IAM role that allows your Amazon ECS container task to make
            calls to other AWS services.
          END
        }

        attribute "execution_role_arn" {
          type        = string
          description = <<-END
            ARN of the task execution role that the Amazon ECS container agent
            and the Docker daemon can assume.
          END
        }

        attribute "network_mode" {
          type        = string
          default     = "bridge"
          description = <<-END
            Docker networking mode to use for the containers in the task.
            Valid values are `none`, `bridge`, `awsvpc`, and `host`.
          END
        }

        attribute "cpu" {
          type        = string
          description = <<-END
            Number of cpu units used by the task. If the
            `requires_compatibilities` is `FARGATE` this field is required.
          END
        }

        attribute "memory" {
          type        = string
          description = <<-END
            Amount (in MiB) of memory used by the task. If the
            `requires_compatibilities` is `FARGATE` this field is required.
          END
        }

        attribute "tags" {
          type        = map(string)
          default     = {}
          description = <<-END
            Key-value map of resource tags. If configured with a provider
            `default_tags` configuration block present, tags with matching keys
            will overwrite those defined at the provider-level. This attribute
            is merged with `module_tags`.
          END
        }
      }
    }

    section {
      title = "Module Configuration"

      variable "module_enabled" {
        type        = bool
        default     = true
        description = <<-END
          Specifies whether resources in the module will be created.
        END
      }

      variable "module_tags" {
        type           = map(string)
        default        = {}
        description    = <<-END
          A map of tags that will be applied to all created resources that accept tags.
          Tags defined with `module_tags` can be overwritten by resource-specific tags.
        END
        readme_example = <<-END
          module_tags = {
            environment = "staging"
            team        = "platform"
          }
        END
      }

      variable "module_depends_on" {
        type           = list(dependency)
        description    = <<-END
          A list of dependencies.
          Any object can be _assigned_ to this list to define a hidden external dependency.
        END
        default        = []
        readme_example = <<-END
          module_depends_on = [
            null_resource.name
          ]
        END
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported in the outputs of the module:
    END

    output "ecs_service" {
      type        = object(ecs_service)
      description = <<-END
        All attributes of the created `aws_ecs_service` resource.
      END
    }

    output "ecs_task_definition" {
      type        = object(ecs_task_definition)
      description = <<-END
        All attributes of the created `aws_ecs_task_definition` resource.
      END
    }

    output "module_enabled" {
      type        = bool
      description = <<-END
        Whether this module is enabled.
      END
    }

    output "module_tags" {
      type        = map(string)
      description = <<-END
        The map of tags that are being applied to all created resources that accept tags.
      END
    }
  }

  section {
    title = "External Documentation"

    section {
      title   = "AWS Documentation IAM"
      content = <<-END
        - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html
      END
    }

    section {
      title   = "Terraform AWS Provider Documentation"
      content = <<-END
        - Service: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
        - Task Definition: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      [Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
      that solves development, automation and security challenges in cloud infrastructure.

      Our vision is to massively reduce time and overhead for teams to manage and
      deploy production-grade and secure cloud infrastructure.

      We offer commercial support for all of our modules and encourage you to reach out
      if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
      [Community Slack channel][slack].
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-aws-ecs-service"
  }
  ref "hello@mineiros.io" {
    value = " mailto:hello@mineiros.io"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "releases-aws-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-aws/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://mineiros.io/slack"
  }
  ref "terraform" {
    value = "https://www.terraform.io"
  }
  ref "aws" {
    value = "https://aws.amazon.com/"
  }
  ref "semantic versioning (semver)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/examples"
  }
  ref "issues" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/issues"
  }
  ref "license" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/LICENSE"
  }
  ref "makefile" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/Makefile"
  }
  ref "pull requests" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/pulls"
  }
  ref "contribution guidelines" {
    value = "https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/CONTRIBUTING.md"
  }
}
