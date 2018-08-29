output "alb_security_group_id" {
  description = "Security Group ID assigned to the ALB."
  value       = "${aws_security_group.alb_sg.id}"
}

output "alb_target_group_id" {
  description = "ID of the target group with the HTTPS listener."
  value       = "${aws_lb_target_group.https.id}"
}

output "alb_arn" {
  description = "The ARN of the ALB."
  value       = "${aws_lb.main.arn}"
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = "${aws_lb.main.dns_name}"
}

output "alb_listener_arn" {
  description = "The ARN associated with the HTTPS listener on the ALB."
  value       = "${aws_lb_listener.https.arn}"
}

output "alb_zone_id" {
  description = "Route53 hosted zone ID associated with the ALB."
  value       = "${aws_lb.main.zone_id}"
}
