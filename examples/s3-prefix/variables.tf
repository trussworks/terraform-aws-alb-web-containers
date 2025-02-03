variable "logs_bucket" {
  description = "S3 Log Bucket to Log to."
  type        = string
}

variable "logs_prefix" {
  description = "Prefix to attach to log ouptput. Typically 's3/<name>'."
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "test_name" {
  description = "App Name"
  type        = string
}
