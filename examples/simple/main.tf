locals {
  environment        = "test"
  zone_name          = "infra-test.truss.coffee"
  container_protocol = "HTTP"
  container_port     = "8080"
  health_check_path  = "/"
}

module "alb" {
  source = "../../"

  name           = var.test_name
  environment    = local.environment
  logs_s3_bucket = var.logs_bucket == "" ? "" : module.logs[0].aws_logs_bucket

  alb_vpc_id                  = module.vpc.vpc_id
  alb_subnet_ids              = module.vpc.public_subnets
  alb_default_certificate_arn = module.acm-cert.acm_arn

  container_port     = local.container_port
  container_protocol = local.container_protocol
  health_check_path  = local.health_check_path
}

module "logs" {
  count = var.logs_bucket == "" ? 0 : 1

  source         = "trussworks/logs/aws"
  version        = "~> 10"
  s3_bucket_name = var.logs_bucket
  force_destroy  = true
  alb_logs_prefixes = [
    "alb/${var.test_name}-${local.environment}"
  ]
}

module "acm-cert" {
  source  = "trussworks/acm-cert/aws"
  version = "~> 3"

  domain_name = "${var.test_name}.${local.zone_name}"
  environment = local.environment
  zone_name   = local.zone_name
}

data "aws_route53_zone" "infra_truss_coffee" {
  name = local.zone_name
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.infra_truss_coffee.zone_id
  name    = var.test_name
  type    = "CNAME"
  ttl     = "300"
  records = [module.alb.alb_dns_name]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.64.0"

  name            = var.test_name
  cidr            = "10.0.0.0/16"
  azs             = var.vpc_azs
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = ["10.0.104.0/24", "10.0.105.0/24", "10.0.106.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

#
# KMS
#

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch_logs_allow_kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow logs KMS access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "main" {
  description         = "Key for ECS log encryption"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.cloudwatch_logs_allow_kms.json
}

#
# ECS
#

resource "aws_ecs_cluster" "main" {
  name = var.test_name
}

module "ecs-service" {
  source  = "trussworks/ecs-service/aws"
  version = "~> 5"

  name        = var.test_name
  environment = local.environment

  ecs_cluster     = aws_ecs_cluster.main
  ecs_vpc_id      = module.vpc.vpc_id
  ecs_subnet_ids  = module.vpc.private_subnets
  kms_key_id      = aws_kms_key.main.arn
  ecs_use_fargate = true

  container_image = "golang:alpine"

  associate_alb      = true
  alb_security_group = module.alb.alb_security_group_id
  lb_target_groups = [
    {
      container_port              = local.container_port
      container_health_check_port = local.container_port
      lb_target_group_arn         = module.alb.alb_target_group_id
    }
  ]

}
