variable "logs_bucket" {
  description = "S3 Log Bucket Name"
  type        = string
}

variable "region" {
  description = "AWS Region to provison resources"
  type        = string
}

variable "test_name" {
  description = "App Name"
  type        = string
}
