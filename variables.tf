variable "name" {
  description = "The service name."
  type        = "string"
}

variable "environment" {
  description = "Environment tag, e.g prod."
  type        = "string"
}

variable "logs_s3_bucket" {
  description = "S3 bucket for storing Application Load Balancer logs."
  type        = "string"
}

variable "alb_certificate_arn" {
  description = "The ARN of the certificate to be attached to the ALB."
  type        = "string"
}

variable "alb_vpc_id" {
  description = "VPC ID to be used by the ALB."
  type        = "string"
}

variable "alb_subnet_ids" {
  description = "Subnets IDs for the ALB."
  type        = "list"
}

variable "https_container_health_check_path" {
  description = "The destination for the health check requests to the HTTPS container."
  type        = "string"
  default     = "/"
}

variable "https_container_success_codes" {
  description = "The HTTP codes to use when checking for a successful response from the HTTPS container. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299')."
  type        = "string"
  default     = "200"
}

variable "https_container_port" {
  description = "The port on which the container will receive traffic."
  type        = "string"
  default     = 443
}

variable "https_container_protocol" {
  description = "The protocol to use to connect with the container."
  type        = "string"
  default     = "HTTPS"
}
