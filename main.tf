#
# Security Group - ALB
#

resource "aws_security_group" "alb" {
  count = var.security_group == null ? 1 : 0

  name        = "alb-${var.name}-${var.environment}"
  description = "${var.name}-${var.environment} ALB security group"
  vpc_id      = var.alb_vpc_id

  tags = merge(
    var.security_group_tags,
  )
}

locals {
  security_group  = var.security_group == null ? [aws_security_group.alb[0].id] : [var.security_group]
  security_groups = var.additional_security_groups == null ? local.security_group : concat(var.additional_security_groups, local.security_group)
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_outbound" {
  count = var.security_group == null ? 1 : 0

  description       = "Allow All Outbound."
  security_group_id = aws_security_group.alb[0].id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  count = var.security_group == null && var.allow_public_https ? 1 : 0

  description       = "Allow All HTTPS."
  security_group_id = aws_security_group.alb[0].id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
  count = var.security_group == null && var.allow_public_http ? 1 : 0

  description       = "Allow All HTTP."
  security_group_id = aws_security_group.alb[0].id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

#
# ALB
#

resource "aws_lb" "main" {
  name                       = "${var.name}-${var.environment}"
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_waf_fail_open       = var.enable_waf_fail_open
  internal                   = var.alb_internal
  preserve_host_header       = var.preserve_host_header
  subnets                    = var.alb_subnet_ids
  security_groups            = local.security_groups
  idle_timeout               = var.alb_idle_timeout
  desync_mitigation_mode     = var.desync_mitigation_mode

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    # Skips creating the block if logs_s3_bucket is empty string
    for_each = var.logs_s3_bucket == "" ? [] : ["create block"]
    content {
      enabled = var.enable_access_logs
      bucket  = var.logs_s3_bucket
      prefix  = var.logs_s3_prefix_enabled == true ? (var.logs_s3_prefix == "" ? "alb/${var.name}-${var.environment}" : var.logs_s3_prefix) : ""
    }
  }

  dynamic "connection_logs" {
    for_each = var.logs_s3_bucket == "" ? [] : ["create block"]
    content {
      enabled = var.enable_connection_logs
      bucket  = var.logs_s3_bucket
      prefix  = var.logs_s3_prefix_enabled == true ? (var.logs_s3_prefix == "" ? "alb/${var.name}-${var.environment}" : var.logs_s3_prefix) : ""
    }
  }

}

#
# ALB Target Groups
#

resource "aws_lb_target_group" "https" {
  # Name must be less than or equal to 32 characters, or AWS API returns error.
  # Error: "name" cannot be longer than 32 characters
  name             = coalesce(var.target_group_name, format("ecs-%s-%s-https", var.name, var.environment))
  port             = var.container_port
  protocol         = var.container_protocol
  protocol_version = var.container_protocol_version
  vpc_id           = var.alb_vpc_id
  target_type      = "ip"

  # The amount time for the LB to wait before changing the state of a
  # deregistering target from draining to unused. AWS default is 300 seconds.
  deregistration_delay          = var.deregistration_delay
  slow_start                    = var.slow_start
  load_balancing_algorithm_type = var.load_balancing_algorithm_type

  health_check {
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    protocol            = var.container_protocol
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = var.health_check_success_codes
  }

  # Ensure the ALB exists before things start referencing this target group.
  depends_on = [aws_lb.main]

}

#
# ALB Listeners
#

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = var.alb_default_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.https.id
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "main" {
  count           = length(var.alb_listener_certificate_arns)
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = element(var.alb_listener_certificate_arns, count.index)
}
