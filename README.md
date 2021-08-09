Creates an ALB for serving an HTTPS web app.

Creates the following resources:

* ALB with HTTP (redirect) and HTTPS listeners.
* Target group for the HTTPS listener.
* Security Groups for the ALB.

The HTTP listener redirects to HTTPS.

The HTTPS listener uses a certificate stored in ACM or IAM.

## Terraform Versions

Terraform 0.13. Pin module version to ~> 5.X. Submit pull-requests to master branch.

Terraform 0.12. Pin module version to ~> 4.X. Submit pull-requests to terraform012 branch.

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_target_group.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.app_alb_allow_http_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.app_alb_allow_https_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.app_alb_allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_certificate_arns"></a> [alb\_certificate\_arns](#input\_alb\_certificate\_arns) | The ARNs of the certificates to be attached to the ALB. | `list(string)` | `[]` | no |
| <a name="input_alb_default_certificate_arn"></a> [alb\_default\_certificate\_arn](#input\_alb\_default\_certificate\_arn) | The ARN of the default certificate to be attached to the ALB. | `string` | n/a | yes |
| <a name="input_alb_idle_timeout"></a> [alb\_idle\_timeout](#input\_alb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | If true, the ALB will be internal. Default's to false, the ALB will be public. | `string` | `false` | no |
| <a name="input_alb_ssl_policy"></a> [alb\_ssl\_policy](#input\_alb\_ssl\_policy) | The SSL policy (aka security policy) for the Application Load Balancer that specifies the TLS protocols and ciphers allowed.  See <https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies>. | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_alb_subnet_ids"></a> [alb\_subnet\_ids](#input\_alb\_subnet\_ids) | Subnet IDs for the ALB. Use public subnets for a public ALB and private subnets for an internal ALB. | `list(string)` | n/a | yes |
| <a name="input_alb_vpc_id"></a> [alb\_vpc\_id](#input\_alb\_vpc\_id) | VPC ID to be used by the ALB. | `string` | n/a | yes |
| <a name="input_allow_public_http"></a> [allow\_public\_http](#input\_allow\_public\_http) | Allow inbound access from the Internet to port 80 | `string` | `true` | no |
| <a name="input_allow_public_https"></a> [allow\_public\_https](#input\_allow\_public\_https) | Allow inbound access from the Internet to port 443 | `string` | `true` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port on which the container will receive traffic. | `string` | `443` | no |
| <a name="input_container_protocol"></a> [container\_protocol](#input\_container\_protocol) | The protocol to use to connect with the container. | `string` | `"HTTPS"` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | The amount time for the LB to wait before changing the state of a deregistering target from draining to unused. Default is 90s. | `string` | `90` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag, e.g prod. | `string` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds. | `string` | `30` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The destination for the health check requests to the container. | `string` | `"/"` | no |
| <a name="input_health_check_success_codes"></a> [health\_check\_success\_codes](#input\_health\_check\_success\_codes) | The HTTP codes to use when checking for a successful response from the container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299'). | `string` | `"200"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | The health check timeout. Minimum value 2 seconds, Maximum value 60 seconds. Default 5 seconds. | `string` | `5` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3. | `string` | `3` | no |
| <a name="input_load_balancing_algorithm_type"></a> [load\_balancing\_algorithm\_type](#input\_load\_balancing\_algorithm\_type) | Determines how the load balancer selects targets when routing requests.  Default is round\_robin. | `string` | `"round_robin"` | no |
| <a name="input_logs_s3_bucket"></a> [logs\_s3\_bucket](#input\_logs\_s3\_bucket) | S3 bucket for storing access logs. Set to empty string to disable logs. | `string` | n/a | yes |
| <a name="input_logs_s3_prefix"></a> [logs\_s3\_prefix](#input\_logs\_s3\_prefix) | S3 key prefix for ALB logs | `string` | `"alb"` | no |
| <a name="input_name"></a> [name](#input\_name) | The service name. | `string` | n/a | yes |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of tags to add to the ALB's security group. | `map(string)` | `{}` | no |
| <a name="input_slow_start"></a> [slow\_start](#input\_slow\_start) | The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0. | `number` | `0` | no |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Override the default name of the ALB's target group. Must be less than or equal to 32 characters. Default: ecs-[name]-[environment]-[protocol]. | `string` | `""` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy\_threshold. Defaults to 3. | `string` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the ALB. |
| <a name="output_alb_arn_suffix"></a> [alb\_arn\_suffix](#output\_alb\_arn\_suffix) | The ARN Suffix of the ALB for use with CloudWatch Metrics. |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the ALB. |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | The ID of the ALB. |
| <a name="output_alb_listener_arn"></a> [alb\_listener\_arn](#output\_alb\_listener\_arn) | The ARN associated with the HTTPS listener on the ALB. |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | Security Group ID assigned to the ALB. |
| <a name="output_alb_target_group_id"></a> [alb\_target\_group\_id](#output\_alb\_target\_group\_id) | ID of the target group with the HTTPS listener. |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Route53 hosted zone ID associated with the ALB. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
pre-commit install --install-hooks
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```shell
make test
```

Or with aws-vault:

```shell
AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- make test
```
