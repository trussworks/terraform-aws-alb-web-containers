<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates an ALB for serving a web app.

Creates the following resources:

* ALB with separate target groups for HTTP and HTTPS.
* Security Groups for the ALB.

The HTTPS listener uses a certificate stored in ACM or IAM.

## Usage

```hcl
module "app_alb" {
  source = "../../modules/aws-alb-web-service"

  name           = "app"
  environment    = "prod"
  logs_s3_bucket = "my-aws-logs"

  alb_vpc_id             = "${module.vpc.vpc_id}"
  alb_subnet_ids         = "${module.vpc.public_subnets}"
  alb_health_check_path  = "/health"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb_certificate_arn | The ARN of the certificate to be attached to the ALB. | string | - | yes |
| alb_subnet_ids | Subnets IDs for the ALB. | list | - | yes |
| alb_vpc_id | VPC ID to be used by the ALB. | string | - | yes |
| environment | Environment tag, e.g prod. | string | - | yes |
| http_container_health_check_path | The destination for the health check requests to the HTTP container. | string | `/` | no |
| http_container_port | The port on which the container will receive traffic. Set to 0 to disable http. | string | `80` | no |
| http_container_protocol | The protocol to use to connect with the container. | string | `HTTP` | no |
| http_container_success_codes | The HTTP codes to use when checking for a successful response from the HTTP container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299'). | string | `200` | no |
| https_container_health_check_path | The destination for the health check requests to the HTTPS container. | string | `/` | no |
| https_container_port | The port on which the container will receive traffic. Set to 0 to disable https. | string | `443` | no |
| https_container_protocol | The protocol to use to connect with the container. | string | `HTTPS` | no |
| https_container_success_codes | The HTTP codes to use when checking for a successful response from the HTTPS container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299'). | string | `200` | no |
| logs_s3_bucket | S3 bucket for storing Application Load Balancer logs. | string | - | yes |
| name | The service name. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn | The ARN of the ALB. |
| alb_dns_name | DNS name of the ALB. |
| alb_http_target_group_id | ID of the target group with the HTTP listener. |
| alb_https_listener_arn | The ARN associated with the HTTPS listener on the ALB. |
| alb_https_target_group_id | ID of the target group with the HTTPS listener. |
| alb_security_group_id | Security Group ID assigned to the ALB. |
| alb_zone_id | Route53 hosted zone ID associated with the ALB. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

