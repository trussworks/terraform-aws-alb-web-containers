/**
 * Creates an ALB for serving an HTTPS web app.
 *
 * Creates the following resources:
 *
 * * ALB with HTTP (redirect) and HTTPS listeners.
 * * Target group for the HTTPS listener.
 * * Security Groups for the ALB.
 *
 * The HTTP listener redirects to HTTPS.
 *
 * The HTTPS listener uses a certificate stored in ACM or IAM.
 *
 * ## Usage
 *
 * ```hcl
 * module "app_alb" {
 *   source = "trussworks/alb-web-containers/aws"
 *
 *   name           = "app"
 *   environment    = "prod"
 *   logs_s3_bucket = "my-aws-logs"
 *
 *   alb_vpc_id                  = "${module.vpc.vpc_id}"
 *   alb_subnet_ids              = "${module.vpc.public_subnets}"
 *   alb_default_certificate_arn = "${aws_acm_certificate.cert.arn}"
 *
 *   container_port    = "443"
 *   health_check_path = "/health"
 * }
 * ```
 */

#
# SG - ALB
#

resource "aws_security_group" "alb_sg" {
  name        = "alb-${var.name}-${var.environment}"
  description = "${var.name}-${var.environment} ALB security group"
  vpc_id      = "${var.alb_vpc_id}"

  tags = {
    Name        = "alb-${var.name}-${var.environment}"
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

resource "aws_security_group_rule" "app_alb_allow_outbound" {
  description       = "All outbound"

  security_group_id = "${aws_security_group.alb_sg.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_alb_allow_https_from_world" {
  count = "${var.allow_public_https}"

  description       = "Allow in HTTPS"
  security_group_id = "${aws_security_group.alb_sg.id}"

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_alb_allow_http_from_world" {
  count = "${var.allow_public_http}"

  description       = "Allow in HTTP"
  security_group_id = "${aws_security_group.alb_sg.id}"

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
  internal        = "${var.alb_internal}"
  subnets         = ["${var.alb_subnet_ids}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]

  access_logs {
    enabled = true
    bucket  = "${var.logs_s3_bucket}"
    prefix  = "alb/${var.name}-${var.environment}"
  }

  tags = {
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

resource "aws_lb_target_group" "https" {
  name        = "ecs-${var.name}-${var.environment}-https"
  port        = "${var.container_port}"
  protocol    = "${var.container_protocol}"
  vpc_id      = "${var.alb_vpc_id}"
  target_type = "ip"

  # The amount time for the LB to wait before changing the state of a
  # deregistering target from draining to unused. AWS default is 300 seconds.
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    timeout             = "${var.health_check_timeout}"
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    protocol            = "${var.container_protocol}"
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    matcher             = "${var.health_check_success_codes}"
  }

  # Ensure the ALB exists before things start referencing this target group.
  depends_on = ["aws_lb.main"]

  tags = {
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.main.id}"
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
  load_balancer_arn = "${aws_lb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "${var.alb_ssl_policy}"
  certificate_arn   = "${var.alb_default_certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.https.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "main" {
  count           = "${length(var.alb_certificate_arns)}"
  listener_arn    = "${aws_lb_listener.https.arn}"
  certificate_arn = "${element(var.alb_certificate_arns, count.index)}"
}
