output "dns_endpoint" {
  description = "DNS Endpoint"
  value       = "${var.test_name}.${local.zone_name}"
}
