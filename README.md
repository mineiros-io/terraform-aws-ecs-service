[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>](https://mineiros.io/?ref=terraform-aws-ecs-service)

[![Build Status](https://github.com/mineiros-io/terraform-aws-ecs-service/workflows/Tests/badge.svg)](https://github.com/mineiros-io/terraform-aws-ecs-service/actions)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-ecs-service.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-aws-ecs-service/releases)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version](https://img.shields.io/badge/AWS-3.5-F8991D.svg?logo=terraform)](https://github.com/terraform-providers/terraform-provider-aws/releases)
[![Join Slack](https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack)](https://mineiros.io/slack)

# terraform-aws-ecs-service

A [Terraform] module to create and manage
[Amazon ECS Services](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html)
on [Amazon Web Services (AWS)][aws].

**_This module supports Terraform version 1
and is compatible with the Terraform AWS Provider version 3.5 to 4.0**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.


- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Main Resource Configuration](#main-resource-configuration)
  - [Extended Resource Configuration](#extended-resource-configuration)
  - [Module Configuration](#module-configuration)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [AWS Documentation IAM](#aws-documentation-iam)
  - [Terraform AWS Provider Documentation](#terraform-aws-provider-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

This module implements the following Terraform resources

- `aws_ecs_service`
- `aws_ecs_task_definition`

## Getting Started

Most common usage of the module:

```hcl
module "terraform-aws-ecs-service" {
  source = "git@github.com:mineiros-io/terraform-aws-ecs-service.git?ref=v0.0.1"

  name = "name-of-service"
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Main Resource Configuration

- [**`name`**](#var-name): *(**Required** `string`)*<a name="var-name"></a>

  Name of the service (up to 255 letters, numbers, hyphens, and
  underscores).

- [**`cluster`**](#var-cluster): *(**Required** `string`)*<a name="var-cluster"></a>

  The Amazon Resource Name (ARN) of the ECS Cluster where this service
  should run.

- [**`launch_type`**](#var-launch_type): *(Optional `string`)*<a name="var-launch_type"></a>

  Launch type that will be used to run your service. The valid values
  are `EC2`, `FARGATE`, and `EXTERNAL`.

  Default is `"EC2"`.

- [**`network_configuration`**](#var-network_configuration): *(Optional `object(network_configuration)`)*<a name="var-network_configuration"></a>

  Network configuration for the service. This parameter is required for
  task definitions that use the awsvpc network mode to receive their
  own Elastic Network Interface, and it is not supported for other
  network modes.

  The `network_configuration` object accepts the following attributes:

  - [**`subnets`**](#attr-network_configuration-subnets): *(**Required** `set(string)`)*<a name="attr-network_configuration-subnets"></a>

    Subnets associated with the task or service.

  - [**`security_groups`**](#attr-network_configuration-security_groups): *(Optional `set(string)`)*<a name="attr-network_configuration-security_groups"></a>

    Security groups associated with the task or service. If you do not
    specify a security group, the default security group for the VPC is
    used.

  - [**`assign_public_ip`**](#attr-network_configuration-assign_public_ip): *(Optional `bool`)*<a name="attr-network_configuration-assign_public_ip"></a>

    Assign a public IP address to the ENI (Fargate launch type only).
    Valid values are `true` or `false`.

- [**`capacity_provider_strategy`**](#var-capacity_provider_strategy): *(Optional `set(capacity_provider_strategy)`)*<a name="var-capacity_provider_strategy"></a>

  Capacity provider strategies to use for the service. Can be one or
  more. These can be updated without destroying and recreating the
  service only if `force_new_deployment = true` and not changing from
  0 `capacity_provider_strategy` blocks to greater than 0, or vice versa.

  Default is `[]`.

  Each `capacity_provider_strategy` object in the set accepts the following attributes:

  - [**`capacity_provider`**](#attr-capacity_provider_strategy-capacity_provider): *(**Required** `string`)*<a name="attr-capacity_provider_strategy-capacity_provider"></a>

    Short name of the capacity provider.

  - [**`weight`**](#attr-capacity_provider_strategy-weight): *(**Required** `number`)*<a name="attr-capacity_provider_strategy-weight"></a>

    Relative percentage of the total number of launched tasks that
    should use the specified capacity provider.

  - [**`base`**](#attr-capacity_provider_strategy-base): *(Optional `number`)*<a name="attr-capacity_provider_strategy-base"></a>

    Number of tasks, at a minimum, to run on the specified capacity
    provider. Only one capacity provider in a capacity provider strategy
    can have a base defined.

- [**`deployment_circuit_breaker`**](#var-deployment_circuit_breaker): *(Optional `list(deployment_circuit_breaker)`)*<a name="var-deployment_circuit_breaker"></a>

  Configuration block for deployment circuit breaker.

  Default is `[]`.

  Each `deployment_circuit_breaker` object in the list accepts the following attributes:

  - [**`enable`**](#attr-deployment_circuit_breaker-enable): *(Optional `bool`)*<a name="attr-deployment_circuit_breaker-enable"></a>

    Whether to enable the deployment circuit breaker logic for the
    service.

    Default is `true`.

  - [**`rollback`**](#attr-deployment_circuit_breaker-rollback): *(**Required** `bool`)*<a name="attr-deployment_circuit_breaker-rollback"></a>

    Whether to enable Amazon ECS to roll back the service if a service
    deployment fails. If rollback is enabled, when a service deployment
    fails, the service is rolled back to the last deployment that
    completed successfully.

- [**`deployment_controller_type`**](#var-deployment_controller_type): *(Optional `string`)*<a name="var-deployment_controller_type"></a>

  The type of the deployment controller. Valid values: `CODE_DEPLOY`,
  `ECS`, `EXTERNAL`.

  Default is `"ECS"`.

- [**`deployment_maximum_percent`**](#var-deployment_maximum_percent): *(Optional `number`)*<a name="var-deployment_maximum_percent"></a>

  The upper limit (as a percentage of `var.desired_count`) of the
  number of running tasks that can be running in a service during a
  deployment. Not valid when using the `DAEMON` scheduling strategy.
  If settings this to more than `100` means that during a deployment,
  ECS will deploy new instances of a task before undeploying the old
  ones.

  Default is `200`.

- [**`deployment_minimum_healthy_percent`**](#var-deployment_minimum_healthy_percent): *(Optional `number`)*<a name="var-deployment_minimum_healthy_percent"></a>

  The lower limit (as a percentage of `desired_count`) of the number of
  running tasks that must remain running and healthy in a service during
  a deployment. Setting this to less than 100 means that during a
  deployment, ECS may undeploy old instances of a Task before deploying
  new ones.

  Default is `100`.

- [**`desired_count`**](#var-desired_count): *(Optional `number`)*<a name="var-desired_count"></a>

  Number of instances of the task definition to place and keep running.
  Do not specify if using the `DAEMON` scheduling strategy.

  Default is `0`.

- [**`enable_ecs_managed_tags`**](#var-enable_ecs_managed_tags): *(Optional `bool`)*<a name="var-enable_ecs_managed_tags"></a>

  Specifies whether to enable Amazon ECS managed tags for the tasks
  within the service.

  Default is `false`.

- [**`enable_execute_command`**](#var-enable_execute_command): *(Optional `bool`)*<a name="var-enable_execute_command"></a>

  Specifies whether to enable Amazon ECS Exec for the tasks within the
  service.

  Default is `false`.

- [**`force_new_deployment`**](#var-force_new_deployment): *(Optional `bool`)*<a name="var-force_new_deployment"></a>

  Enable to force a new task deployment of the service. This can be used
  to update tasks to use a newer Docker image with same image/tag
  combination (e.g. `myimage:latest`), roll Fargate tasks onto a newer
  platform version, or immediately deploy `ordered_placement_strategy`
  and `placement_constraints updates`.

  Default is `false`.

- [**`wait_for_steady_state`**](#var-wait_for_steady_state): *(Optional `bool`)*<a name="var-wait_for_steady_state"></a>

  If `true`, Terraform will wait for the service to reach a steady
  state—as in, the ECS tasks you wanted are actually deployed—before
  `apply` is considered complete.

  Default is `false`.

- [**`ordered_placement_strategy`**](#var-ordered_placement_strategy): *(Optional `list(ordered_placement_strategy)`)*<a name="var-ordered_placement_strategy"></a>

  Service level strategy rules that are taken into consideration during
  task placement. List from top to bottom in order of precedence.
  Updates to this configuration will take effect next task deployment
  unless `force_new_deployment` is enabled. The maximum number of
  `ordered_placement_strategy` blocks is `5`. For details please
  see [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#ordered_placement_strategy).

  Default is `[]`.

  Each `ordered_placement_strategy` object in the list accepts the following attributes:

  - [**`type`**](#attr-ordered_placement_strategy-type): *(**Required** `string`)*<a name="attr-ordered_placement_strategy-type"></a>

    Type of placement strategy. Must be one of: `binpack`, `random`, or
    `spread`.

  - [**`field`**](#attr-ordered_placement_strategy-field): *(Optional `string`)*<a name="attr-ordered_placement_strategy-field"></a>

    For the `spread` placement strategy, valid values are `instanceId` (or
    `host`, which has the same effect), or any platform or custom
    attribute that is applied to a container instance. For the `binpack`
    type, valid values are `memory` and `cpu`. For the `random` type, this
    attribute is not needed. For more information, see
    [Placement Strategy](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PlacementStrategy.html).

- [**`placement_constraints`**](#var-placement_constraints): *(Optional `set(placement_constraint)`)*<a name="var-placement_constraints"></a>

  Rules that are taken into consideration during task placement. Updates
  to this configuration will take effect next task deployment unless
  `force_new_deployment` is enabled. Maximum number of
  `placement_constraints` is `10`.

  Default is `[]`.

  Each `placement_constraint` object in the set accepts the following attributes:

  - [**`type`**](#attr-placement_constraints-type): *(**Required** `string`)*<a name="attr-placement_constraints-type"></a>

    Type of constraint. The only valid values at this time are
    `memberOf` and `distinctInstance`.

  - [**`expression`**](#attr-placement_constraints-expression): *(Optional `string`)*<a name="attr-placement_constraints-expression"></a>

    Cluster Query Language expression to apply to the constraint. Does
    not need to be specified for the `distinctInstance` type. For more
    information, see [Cluster Query Language](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-query-language.html)
    in the Amazon EC2 Container Service Developer Guide.

- [**`load_balancers`**](#var-load_balancers): *(Optional `set(load_balancer)`)*<a name="var-load_balancers"></a>

  Configuration block for load balancers.

  Each `load_balancer` object in the set accepts the following attributes:

  - [**`elb_name`**](#attr-load_balancers-elb_name): *(Optional `string`)*<a name="attr-load_balancers-elb_name"></a>

    Name of the ELB (Classic) to associate with the service.

  - [**`target_group_arn`**](#attr-load_balancers-target_group_arn): *(Optional `string`)*<a name="attr-load_balancers-target_group_arn"></a>

    ARN of the Load Balancer target group to associate with the service.

  - [**`container_name`**](#attr-load_balancers-container_name): *(**Required** `string`)*<a name="attr-load_balancers-container_name"></a>

    Name of the container to associate with the load balancer (as it
    appears in a container definition).

  - [**`container_port`**](#attr-load_balancers-container_port): *(**Required** `number`)*<a name="attr-load_balancers-container_port"></a>

    Port on the container to associate with the load balancer.

- [**`health_check_grace_period_seconds`**](#var-health_check_grace_period_seconds): *(Optional `number`)*<a name="var-health_check_grace_period_seconds"></a>

  Seconds to ignore failing load balancer health checks on newly
  instantiated tasks to prevent premature shutdown, up to
  `2,147,483,647`. Only valid for services configured to use load
  balancers.

  Default is `0`.

- [**`iam_role_arn`**](#var-iam_role_arn): *(Optional `string`)*<a name="var-iam_role_arn"></a>

  ARN of the IAM role that allows Amazon ECS to make calls to your load
  balancer on your behalf. This parameter is required if you are using
  a load balancer with your service, but only if your task definition
  does not use the `awsvpc` network mode. If using `awsvpc` network
  mode, do not specify this role. If your account has already created
  the Amazon ECS service-linked role, that role is used by default for
  your service unless you specify a role here.

- [**`platform_version`**](#var-platform_version): *(Optional `string`)*<a name="var-platform_version"></a>

  The platform version on which to run your service. Only applicable for
  `launch_type` set to `FARGATE`. Defaults to `LATEST`.

  Default is `"LATEST"`.

- [**`scheduling_strategy`**](#var-scheduling_strategy): *(Optional `string`)*<a name="var-scheduling_strategy"></a>

  Scheduling strategy to use for the service. The valid values are
  `REPLICA` and `DAEMON`.  Note that Tasks using the Fargate launch
  type or the `CODE_DEPLOY` or `EXTERNAL` deployment controller
  types don't support the `DAEMON` scheduling strategy.

  Default is `"REPLICA"`.

- [**`propagate_tags`**](#var-propagate_tags): *(Optional `string`)*<a name="var-propagate_tags"></a>

  Whether tags should be propogated to the tasks from the service or
  from the task definition. Valid values are `SERVICE` and
  `TASK_DEFINITION`. Defaults to `SERVICE`. If set to null, no tags
  are created for tasks.

  Default is `"SERVICE"`.

- [**`service_tags`**](#var-service_tags): *(Optional `map(string)`)*<a name="var-service_tags"></a>

  A map of tags to apply to the ECS service. Each item in this list
  should be a map with the parameters key and value.

  Default is `{}`.

- [**`service_registries`**](#var-service_registries): *(Optional `list(service_registry)`)*<a name="var-service_registries"></a>

  Service discovery registries for the service. The maximum number of
  `service_registries` blocks is `1`.

  Default is `[]`.

  Each `service_registry` object in the list accepts the following attributes:

  - [**`registry_arn`**](#attr-service_registries-registry_arn): *(**Required** `string`)*<a name="attr-service_registries-registry_arn"></a>

    ARN of the Service Registry. The currently supported service
    registry is Amazon Route 53 Auto Naming
    Service(`aws_service_discovery_service`). For more information,
    see [Service](https://docs.aws.amazon.com/Route53/latest/APIReference/Welcome.html).

  - [**`port`**](#attr-service_registries-port): *(Optional `number`)*<a name="attr-service_registries-port"></a>

    Port value used if your Service Discovery service specified a
    SRV record.

  - [**`container_port`**](#attr-service_registries-container_port): *(Optional `number`)*<a name="attr-service_registries-container_port"></a>

    Port value, already specified in the task definition, to be used
    for your service discovery service.

  - [**`container_name`**](#attr-service_registries-container_name): *(Optional `string`)*<a name="attr-service_registries-container_name"></a>

    Container name value, already specified in the task definition, to
    be used for your service discovery service.

### Extended Resource Configuration

- [**`task_definition`**](#var-task_definition): *(**Required** `object(task_definition)`)*<a name="var-task_definition"></a>

  Task definition configuration of the service.

  The `task_definition` object accepts the following attributes:

  - [**`family`**](#attr-task_definition-family): *(Optional `string`)*<a name="attr-task_definition-family"></a>

    A unique name for your task definition.

    Default is `var.name`.

  - [**`container_definitions`**](#attr-task_definition-container_definitions): *(**Required** `string`)*<a name="attr-task_definition-container_definitions"></a>

    A list of valid [container definitions](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html)
    provided as a single valid JSON document. Please note that you
    should only provide values that are part of the container definition
    document. For a detailed description of what parameters are
    available, see the [Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
    section from the official
    [Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html).

  - [**`task_role_arn`**](#attr-task_definition-task_role_arn): *(Optional `string`)*<a name="attr-task_definition-task_role_arn"></a>

    ARN of IAM role that allows your Amazon ECS container task to make
    calls to other AWS services.

  - [**`execution_role_arn`**](#attr-task_definition-execution_role_arn): *(Optional `string`)*<a name="attr-task_definition-execution_role_arn"></a>

    ARN of the task execution role that the Amazon ECS container agent
    and the Docker daemon can assume.

  - [**`network_mode`**](#attr-task_definition-network_mode): *(Optional `string`)*<a name="attr-task_definition-network_mode"></a>

    Docker networking mode to use for the containers in the task.
    Valid values are `none`, `bridge`, `awsvpc`, and `host`.

    Default is `"bridge"`.

  - [**`cpu`**](#attr-task_definition-cpu): *(Optional `string`)*<a name="attr-task_definition-cpu"></a>

    Number of cpu units used by the task. If the
    `requires_compatibilities` is `FARGATE` this field is required.

  - [**`memory`**](#attr-task_definition-memory): *(Optional `string`)*<a name="attr-task_definition-memory"></a>

    Amount (in MiB) of memory used by the task. If the
    `requires_compatibilities` is `FARGATE` this field is required.

  - [**`tags`**](#attr-task_definition-tags): *(Optional `map(string)`)*<a name="attr-task_definition-tags"></a>

    Key-value map of resource tags. If configured with a provider
    `default_tags` configuration block present, tags with matching keys
    will overwrite those defined at the provider-level. This attribute
    is merged with `module_tags`.

    Default is `{}`.

### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

- [**`module_tags`**](#var-module_tags): *(Optional `map(string)`)*<a name="var-module_tags"></a>

  A map of tags that will be applied to all created resources that accept tags.
  Tags defined with `module_tags` can be overwritten by resource-specific tags.

  Default is `{}`.

  Example:

  ```hcl
  module_tags = {
    environment = "staging"
    team        = "platform"
  }
  ```

- [**`module_depends_on`**](#var-module_depends_on): *(Optional `list(dependency)`)*<a name="var-module_depends_on"></a>

  A list of dependencies.
  Any object can be _assigned_ to this list to define a hidden external dependency.

  Default is `[]`.

  Example:

  ```hcl
  module_depends_on = [
    null_resource.name
  ]
  ```

## Module Outputs

The following attributes are exported in the outputs of the module:

- [**`ecs_service`**](#output-ecs_service): *(`object(ecs_service)`)*<a name="output-ecs_service"></a>

  All attributes of the created `aws_ecs_service` resource.

- [**`ecs_task_definition`**](#output-ecs_task_definition): *(`object(ecs_task_definition)`)*<a name="output-ecs_task_definition"></a>

  All attributes of the created `aws_ecs_task_definition` resource.

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

- [**`module_tags`**](#output-module_tags): *(`map(string)`)*<a name="output-module_tags"></a>

  The map of tags that are being applied to all created resources that accept tags.

## External Documentation

### AWS Documentation IAM

- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html

### Terraform AWS Provider Documentation

- Service: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
- Task Definition: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

[Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
that solves development, automation and security challenges in cloud infrastructure.

Our vision is to massively reduce time and overhead for teams to manage and
deploy production-grade and secure cloud infrastructure.

We offer commercial support for all of our modules and encourage you to reach out
if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
[Community Slack channel][slack].

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-aws-ecs-service
[hello@mineiros.io]: mailto:hello@mineiros.io
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[releases-aws-provider]: https://github.com/terraform-providers/terraform-provider-aws/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[aws]: https://aws.amazon.com/
[semantic versioning (semver)]: https://semver.org/
[variables.tf]: https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-aws-ecs-service/issues
[license]: https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-aws-ecs-service/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-aws-ecs-service/blob/main/CONTRIBUTING.md
