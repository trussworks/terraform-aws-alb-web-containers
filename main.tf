#
# SG - ALB
#

resource "aws_security_group" "alb_sg" {
  count = var.security_group == "" ? 1 : 0

  name        = "alb-${var.name}-${var.environment}"
  description = "${var.name}-${var.environment} ALB security group"
  vpc_id      = var.alb_vpc_id

  tags = merge(
    var.security_group_tags,
  )
}

locals {
  security_group = var.security_group == "" ? aws_security_group.alb_sg[0].id : var.security_group
}

resource "aws_security_group_rule" "app_alb_allow_outbound" {
  count = var.security_group == "" ? 1 : 0

  description       = "All outbound"
  security_group_id = aws_security_group.alb_sg[0].id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_alb_allow_https_from_world" {
  count = var.security_group == "" && var.allow_public_https ? 1 : 0

  description       = "Allow in HTTPS"
  security_group_id = aws_security_group.alb_sg[0].id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_alb_allow_http_from_world" {
  count = var.security_group == "" && var.allow_public_http ? 1 : 0

  description       = "Allow in HTTP"
  security_group_id = aws_security_group.alb_sg[0].id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

#
# ALB
#

resource "aws_lb" "main" {
  name            = "${var.name}-${var.environment}"
  internal        = var.alb_internal
  subnets         = var.alb_subnet_ids
  security_groups = [local.security_group]
  idle_timeout    = var.alb_idle_timeout

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    # Skips creating the block if logs_s3_bucket is empty string
    for_each = var.logs_s3_bucket == "" ? [] : ["create block"]
    content {
      enabled = true
      bucket  = var.logs_s3_bucket
      prefix  = var.logs_s3_prefix_enabled == true ? (var.logs_s3_prefix == "" ? "alb/${var.name}-${var.environment}" : var.logs_s3_prefix) : ""
    }
  }

}

resource "aws_lb_target_group" "https" {
  # Name must be less than or equal to 32 characters, or AWS API returns error.
  # Error: "name" cannot be longer than 32 characters
  name        = coalesce(var.target_group_name, format("ecs-%s-%s-https", var.name, var.environment))
  port        = var.container_port
  protocol    = var.container_protocol
  vpc_id      = var.alb_vpc_id
  target_type = "ip"

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
  count           = length(var.alb_certificate_arns)
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = element(var.alb_certificate_arns, count.index)
}
