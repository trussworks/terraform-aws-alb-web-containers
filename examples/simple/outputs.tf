output "alb_url" {
  value = "${var.test_name}.${local.zone_name}"
}
