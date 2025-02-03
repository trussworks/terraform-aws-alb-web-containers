output "dns_endpoint" {
  description = "DNS Endpout"
  value       = "${var.test_name}.${local.zone_name}"
}
