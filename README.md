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

  name                   = "app"
  environment            = "prod"
  enable_access_logs     = true
  enable_connection_logs = true
  logs_s3_bucket         = "my-aws-logs"

  alb_vpc_id                  = aws.vpc.vpc_id
  alb_subnet_ids              = var.subnet_ids
  alb_default_certificate_arn = aws_acm_certificate.cert.arn

  container_port    = "443"
  health_check_path = "/health"
}
```

<!-- BEGIN_TF_DOCS -->
***

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb_default_certificate_arn | The ARN of the default certificate to be attached to the ALB. | `string` | n/a | yes |
| alb_subnet_ids | Subnet IDs for the ALB. Use public subnets for a public ALB and private subnets for an internal ALB. | `list(string)` | n/a | yes |
| alb_vpc_id | VPC ID to be used by the ALB. | `string` | n/a | yes |
| environment | Environment tag, e.g prod. | `string` | n/a | yes |
| name | The service name. | `string` | n/a | yes |
| additional_security_groups | A list of additional Security Groups to attach to the ALB. | `list(string)` | `null` | no |
| alb_idle_timeout | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| alb_internal | If true, the ALB will be internal. Default's to false, the ALB will be public. | `string` | `false` | no |
| alb_listener_certificate_arns | The ARNs of the additional certificates to be attached to the HTTPS Listener on the ALB. Does not replace the default certifcate on the listener. | `list(string)` | `[]` | no |
| alb_ssl_policy | The SSL policy (aka security policy) for the Application Load Balancer that specifies the TLS protocols and ciphers allowed.  See [https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html) | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| allow_public_http | Allow inbound access from the Internet to port 80. | `string` | `true` | no |
| allow_public_https | Allow inbound access from the Internet to port 443. | `string` | `true` | no |
| container_port | The port on which the container will receive traffic. | `string` | `443` | no |
| container_protocol | The protocol to use to connect with the container. | `string` | `"HTTPS"` | no |
| container_protocol_version | The protocol version to use with the container. | `string` | `"HTTP1"` | no |
| deregistration_delay | The amount time for the LB to wait before changing the state of a deregistering target from draining to unused. Default is 90s. | `string` | `90` | no |
| desync_mitigation_mode | How the load balancer handles requests that might pose a security risk to an application due to HTTP desync. Valid values are monitor, defensive (default), strictest. | `string` | `"defensive"` | no |
| drop_invalid_header_fields | Whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is true. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. | `bool` | `true` | no |
| enable_access_logs | Enable ALB Access Logs. | `bool` | `false` | no |
| enable_connection_logs | Enable ALB Connection Logs. | `bool` | `false` | no |
| enable_deletion_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancera. | `bool` | `false` | no |
| enable_waf_fail_open | Whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to false. | `bool` | `false` | no |
| health_check_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds. | `string` | `30` | no |
| health_check_path | The destination for the health check requests to the container. | `string` | `"/"` | no |
| health_check_success_codes | The HTTP codes to use when checking for a successful response from the container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299'). | `string` | `"200"` | no |
| health_check_timeout | The health check timeout. Minimum value 2 seconds, Maximum value 60 seconds. Default 5 seconds. | `string` | `5` | no |
| healthy_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3. | `string` | `3` | no |
| load_balancing_algorithm_type | Determines how the load balancer selects targets when routing requests.  Default is round_robin. | `string` | `"round_robin"` | no |
| logs_s3_bucket | S3 bucket for storing access logs. Set to empty string to disable logs. | `string` | `null` | no |
| logs_s3_prefix | Overrides prefix for ALB logs | `string` | `""` | no |
| logs_s3_prefix_enabled | Toggle for ALB logs S3 prefix | `bool` | `true` | no |
| preserve_host_header | Whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change. | `bool` | `false` | no |
| security_group | User-defined Security Group for the ALB. Defining a Security Group here will cause the module to not create a Security Group for the ALB. | `string` | `null` | no |
| security_group_tags | A map of tags to add to the ALB's security group. | `map(string)` | `{}` | no |
| slow_start | The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0. | `number` | `0` | no |
| target_group_name | Override the default name of the ALB's target group. Must be less than or equal to 32 characters. Default: [environment]-[name]-ecs-[protocol]. | `string` | `""` | no |
| unhealthy_threshold | The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3. | `string` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn | The ARN of the ALB. |
| alb_arn_suffix | The ARN Suffix of the ALB for use with CloudWatch Metrics. |
| alb_dns_name | DNS name of the ALB. |
| alb_id | ARN of the load balancer (matches arn). |
| alb_listener_arn | The ARN associated with the HTTPS listener on the ALB. |
| alb_listener_arn_suffix | The ARN suffix associated with the HTTPS listener on the ALB for use with CloudWatch Metrics. |
| alb_security_group_id | Security Group ID assigned to the ALB. |
| alb_target_group_id | ID of the target group with the HTTPS listener. |
| alb_zone_id | Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_target_group.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.alb_allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_allow_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_allow_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

***
<!-- END_TF_DOCS -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
pre-commit install --install-hooks
```
