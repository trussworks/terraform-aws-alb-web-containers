Creates an ALB for serving an HTTPS web app.

Creates the following resources:

- ALB with HTTP (redirect) and HTTPS listeners.
- Target group for the HTTPS listener.
- Security Groups for the ALB.

The HTTP listener redirects to HTTPS.

The HTTPS listener uses a certificate stored in ACM or IAM.

## Usage

```hcl
module "app_alb" {
  source = "trussworks/alb-web-containers/aws"

  name           = "app"
  environment    = "prod"
  logs_s3_bucket = "my-aws-logs"

  alb_vpc_id                  = "${module.vpc.vpc_id}"
  alb_subnet_ids              = "${module.vpc.public_subnets}"
  alb_default_certificate_arn = "${aws_acm_certificate.cert.arn}"

  container_port    = "443"
  health_check_path = "/health"
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 3.0  |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | 4.67.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                      | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)                                                             | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                                           | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                                          | resource |
| [aws_lb_listener_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate)                   | resource |
| [aws_lb_target_group.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)                                  | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                   | resource |
| [aws_security_group_rule.app_alb_allow_http_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)  | resource |
| [aws_security_group_rule.app_alb_allow_https_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.app_alb_allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)         | resource |

## Inputs

| Name                          | Description                                                                                                                                                                                                                                              | Type           | Default                       | Required |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------------------------- | :------: |
| alb_certificate_arns          | The ARNs of the certificates to be attached to the ALB.                                                                                                                                                                                                  | `list(string)` | `[]`                          |    no    |
| alb_default_certificate_arn   | The ARN of the default certificate to be attached to the ALB.                                                                                                                                                                                            | `string`       | n/a                           |   yes    |
| alb_idle_timeout              | The time in seconds that the connection is allowed to be idle.                                                                                                                                                                                           | `number`       | `60`                          |    no    |
| alb_internal                  | If true, the ALB will be internal. Default's to false, the ALB will be public.                                                                                                                                                                           | `string`       | `false`                       |    no    |
| alb_ssl_policy                | The SSL policy (aka security policy) for the Application Load Balancer that specifies the TLS protocols and ciphers allowed. See <https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies>. | `string`       | `"ELBSecurityPolicy-2016-08"` |    no    |
| alb_subnet_ids                | Subnet IDs for the ALB. Use public subnets for a public ALB and private subnets for an internal ALB.                                                                                                                                                     | `list(string)` | n/a                           |   yes    |
| alb_vpc_id                    | VPC ID to be used by the ALB.                                                                                                                                                                                                                            | `string`       | n/a                           |   yes    |
| allow_public_http             | Allow inbound access from the Internet to port 80                                                                                                                                                                                                        | `string`       | `true`                        |    no    |
| allow_public_https            | Allow inbound access from the Internet to port 443                                                                                                                                                                                                       | `string`       | `true`                        |    no    |
| container_port                | The port on which the container will receive traffic.                                                                                                                                                                                                    | `string`       | `443`                         |    no    |
| container_protocol            | The protocol to use to connect with the container.                                                                                                                                                                                                       | `string`       | `"HTTPS"`                     |    no    |
| deregistration_delay          | The amount time for the LB to wait before changing the state of a deregistering target from draining to unused. Default is 90s.                                                                                                                          | `string`       | `90`                          |    no    |
| enable_deletion_protection    | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer                                                                                                                     | `string`       | `false`                       |    no    |
| environment                   | Environment tag, e.g prod.                                                                                                                                                                                                                               | `string`       | n/a                           |   yes    |
| health_check_interval         | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds.                                                                                       | `string`       | `30`                          |    no    |
| health_check_path             | The destination for the health check requests to the container.                                                                                                                                                                                          | `string`       | `"/"`                         |    no    |
| health_check_success_codes    | The HTTP codes to use when checking for a successful response from the container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299').                                                                | `string`       | `"200"`                       |    no    |
| health_check_timeout          | The health check timeout. Minimum value 2 seconds, Maximum value 60 seconds. Default 5 seconds.                                                                                                                                                          | `string`       | `5`                           |    no    |
| healthy_threshold             | The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3.                                                                                                                                | `string`       | `3`                           |    no    |
| load_balancing_algorithm_type | Determines how the load balancer selects targets when routing requests. Default is round_robin.                                                                                                                                                          | `string`       | `"round_robin"`               |    no    |
| logs_s3_bucket                | S3 bucket for storing access logs. Set to empty string to disable logs.                                                                                                                                                                                  | `string`       | n/a                           |   yes    |
| logs_s3_prefix                | Overrides prefix for ALB logs                                                                                                                                                                                                                            | `string`       | `""`                          |    no    |
| logs_s3_prefix_enabled        | Toggle for ALB logs S3 prefix                                                                                                                                                                                                                            | `bool`         | `true`                        |    no    |
| name                          | The service name.                                                                                                                                                                                                                                        | `string`       | n/a                           |   yes    |
| security_group                | SG for the ALB                                                                                                                                                                                                                                           | `string`       | `""`                          |    no    |
| security_group_tags           | A map of tags to add to the ALB's security group.                                                                                                                                                                                                        | `map(string)`  | `{}`                          |    no    |
| slow_start                    | The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0.                                                                                | `number`       | `0`                           |    no    |
| target_group_name             | Override the default name of the ALB's target group. Must be less than or equal to 32 characters. Default: ecs-[name]-[environment]-[protocol].                                                                                                          | `string`       | `""`                          |    no    |
| unhealthy_threshold           | The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3.                                                       | `string`       | `3`                           |    no    |

## Outputs

| Name                  | Description                                                |
| --------------------- | ---------------------------------------------------------- |
| alb_arn               | The ARN of the ALB.                                        |
| alb_arn_suffix        | The ARN Suffix of the ALB for use with CloudWatch Metrics. |
| alb_dns_name          | DNS name of the ALB.                                       |
| alb_id                | The ID of the ALB.                                         |
| alb_listener_arn      | The ARN associated with the HTTPS listener on the ALB.     |
| alb_security_group_id | Security Group ID assigned to the ALB.                     |
| alb_target_group_id   | ID of the target group with the HTTPS listener.            |
| alb_zone_id           | Route53 hosted zone ID associated with the ALB.            |

<!-- END_TF_DOCS -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
pre-commit install --install-hooks
```
