/**
 * Creates an ALB for serving a web app.
 *
 * Creates the following resources:
 *
 * * ALB with separate target groups for HTTP and HTTPS.
 * * Security Groups for the ALB.
 *
 * The HTTPS listener uses a certificate stored in ACM or IAM.

 * ## Usage
 *
 * ```hcl
 * module "app_alb" {
 *   source = "../../modules/aws-alb-web-service"
 *
 *   name           = "app"
 *   environment    = "prod"
 *   logs_s3_bucket = "my-aws-logs"
 *
 *   alb_vpc_id             = "${module.vpc.vpc_id}"
 *   alb_subnet_ids         = "${module.vpc.public_subnets}"
 *   alb_health_check_path  = "/health"
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
    Environment = "${var.environment}"
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
  count = "${var.https_container_port == 0 ? 0 : 1}"

  description       = "Allow in HTTPS"
  security_group_id = "${aws_security_group.alb_sg.id}"

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_alb_allow_http_from_world" {
  count = "${var.http_container_port == 0 ? 0 : 1}"

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

resource "aws_alb" "main" {
  name            = "${var.name}-${var.environment}"
  subnets         = ["${var.alb_subnet_ids}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]

  access_logs {
    enabled = true
    bucket  = "${var.logs_s3_bucket}"
    prefix  = "alb/${var.name}-${var.environment}"
  }

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "https" {
  count = "${var.https_container_port == 0 ? 0 : 1}"

  name        = "ecs-${var.name}-${var.environment}-https"
  port        = "${var.https_container_port}"
  protocol    = "${var.https_container_protocol}"
  vpc_id      = "${var.alb_vpc_id}"
  target_type = "ip"

  # The amount time for the ALB to wait before changing the state of a
  # deregistering target from draining to unused. Default is 300 seconds.
  deregistration_delay = 90

  health_check {
    path     = "${var.https_container_health_check_path}"
    protocol = "${var.https_container_protocol}"
    matcher  = "${var.https_container_success_codes}"
  }

  # Ensure the ALB exists before things start referencing this target group.
  depends_on = ["aws_alb.main"]

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "https" {
  count = "${var.https_container_port == 0 ? 0 : 1}"

  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.https.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "http" {
  count = "${var.http_container_port == 0 ? 0 : 1}"

  name        = "ecs-${var.name}-${var.environment}-http"
  port        = "${var.http_container_port}"
  protocol    = "${var.http_container_protocol}"
  vpc_id      = "${var.alb_vpc_id}"
  target_type = "ip"

  # The amount time for the ALB to wait before changing the state of a
  # deregistering target from draining to unused. Default is 300 seconds.
  deregistration_delay = 10

  health_check {
    path     = "${var.http_container_health_check_path}"
    protocol = "${var.http_container_protocol}"
    matcher  = "${var.http_container_success_codes}"
  }

  # Ensure the ALB exists before things start referencing this target group.
  depends_on = ["aws_alb.main"]

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "http" {
  count = "${var.http_container_port == 0 ? 0 : 1}"

  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.http.id}"
    type             = "forward"
  }
}
