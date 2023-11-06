variable "alb_certificate_arns" {
  description = "The ARNs of the certificates to be attached to the ALB."
  type        = list(string)
  default     = []
}

variable "alb_default_certificate_arn" {
  description = "The ARN of the default certificate to be attached to the ALB."
  type        = string
}

variable "alb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "alb_internal" {
  description = "If true, the ALB will be internal. Default's to false, the ALB will be public."
  type        = string
  default     = false
}

variable "alb_ssl_policy" {
  description = "The SSL policy (aka security policy) for the Application Load Balancer that specifies the TLS protocols and ciphers allowed.  See <https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies>."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "alb_subnet_ids" {
  description = "Subnet IDs for the ALB. Use public subnets for a public ALB and private subnets for an internal ALB."
  type        = list(string)
}

variable "alb_vpc_id" {
  description = "VPC ID to be used by the ALB."
  type        = string
}

variable "allow_public_http" {
  description = "Allow inbound access from the Internet to port 80"
  type        = string
  default     = true
}

variable "allow_public_https" {
  description = "Allow inbound access from the Internet to port 443"
  type        = string
  default     = true
}

variable "container_port" {
  description = "The port on which the container will receive traffic."
  type        = string
  default     = 443
}

variable "container_protocol" {
  description = "The protocol to use to connect with the container."
  type        = string
  default     = "HTTPS"
}

variable "deregistration_delay" {
  description = "The amount time for the LB to wait before changing the state of a deregistering target from draining to unused. Default is 90s."
  type        = string
  default     = 90
}

variable "enable_deletion_protection" {
  description = " If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer"
  type        = string
  default     = false
}

variable "environment" {
  description = "Environment tag, e.g prod."
  type        = string
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds."
  type        = string
  default     = 30
}

variable "health_check_path" {
  description = "The destination for the health check requests to the container."
  type        = string
  default     = "/"
}

variable "health_check_success_codes" {
  description = "The HTTP codes to use when checking for a successful response from the container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299')."
  type        = string
  default     = "200"
}

variable "health_check_timeout" {
  description = "The health check timeout. Minimum value 2 seconds, Maximum value 60 seconds. Default 5 seconds."
  type        = string
  default     = 5
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  type        = string
  default     = 3
}

variable "load_balancing_algorithm_type" {
  description = "Determines how the load balancer selects targets when routing requests.  Default is round_robin."
  type        = string
  default     = "round_robin"
}

variable "logs_s3_bucket" {
  description = "S3 bucket for storing access logs. Set to empty string to disable logs."
  type        = string
}

variable "logs_s3_prefix" {
  description = "Overrides prefix for ALB logs"
  default     = ""
  type        = string
}

variable "logs_s3_prefix_enabled" {
  description = "Toggle for ALB logs S3 prefix"
  default     = true
  type        = bool
}

variable "name" {
  description = "The service name."
  type        = string
}

variable "security_group" {
  description = "SG for the ALB"
  type        = string
  default     = ""
}

variable "security_group_tags" {
  description = "A map of tags to add to the ALB's security group."
  type        = map(string)
  default     = {}
}

variable "slow_start" {
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0."
  type        = number
  default     = 0
}

variable "target_group_name" {
  description = "Override the default name of the ALB's target group. Must be less than or equal to 32 characters. Default: ecs-[name]-[environment]-[protocol]."
  type        = string
  default     = ""
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3."
  type        = string
  default     = 3
}
