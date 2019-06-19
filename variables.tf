variable "name" {
  description = "The service name."
  type        = string
}

variable "environment" {
  description = "Environment tag, e.g prod."
  type        = string
}

variable "logs_s3_bucket" {
  description = "S3 bucket for storing Application Load Balancer logs."
  type        = string
}

variable "alb_default_certificate_arn" {
  description = "The ARN of the default certificate to be attached to the ALB."
  type        = string
}

variable "alb_certificate_arns" {
  description = "The ARNs of the certificates to be attached to the ALB."
  type        = list(string)
  default     = []
}

variable "alb_vpc_id" {
  description = "VPC ID to be used by the ALB."
  type        = string
}

variable "alb_internal" {
  description = "If true, the ALB will be internal. Default's to false, the ALB will be public."
  type        = string
  default     = false
}

variable "alb_subnet_ids" {
  description = "Subnet IDs for the ALB. Use public subnets for a public ALB and private subnets for an internal ALB."
  type        = list(string)
}

variable "alb_ssl_policy" {
  description = "The SSL policy (aka security policy) for the Application Load Balancer that specifies the TLS protocols and ciphers allowed.  See <https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies>."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "deregistration_delay" {
  description = "The amount time for the LB to wait before changing the state of a deregistering target from draining to unused. Default is 90s."
  type        = string
  default     = 90
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds."
  type        = string
  default     = 30
}

variable "health_check_timeout" {
  description = "The health check timeout. Minimum value 2 seconds, Maximum value 60 seconds. Default 5 seconds."
  type        = string
  default     = 5
}

variable "health_check_path" {
  description = "The destination for the health check requests to the container."
  type        = string
  default     = "/"
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  type        = string
  default     = 3
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3."
  type        = string
  default     = 3
}

variable "health_check_success_codes" {
  description = "The HTTP codes to use when checking for a successful response from the container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299')."
  type        = string
  default     = "200"
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

