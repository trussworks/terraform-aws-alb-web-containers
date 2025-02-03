output "alb_arn" {
  description = "The ARN of the ALB."
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "The ARN Suffix of the ALB for use with CloudWatch Metrics."
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "alb_id" {
  description = "ARN of the load balancer (matches arn)."
  value       = aws_lb.main.id
}

output "alb_listener_arn" {
  description = "The ARN associated with the HTTPS listener on the ALB."
  value       = aws_lb_listener.https.arn
}

output "alb_listener_arn_suffix" {
  description = "The ARN suffix associated with the HTTPS listener on the ALB for use with CloudWatch Metrics."
  value       = aws_lb_listener.https.arn
}

output "alb_security_group_id" {
  description = "Security Group ID assigned to the ALB."
  value       = local.security_group
}

output "alb_target_group_id" {
  description = "ID of the target group with the HTTPS listener."
  value       = aws_lb_target_group.https.id
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.main.zone_id
}
