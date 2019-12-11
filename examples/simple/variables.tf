variable "logs_bucket" {
  type = string
}

variable "region" {
  type = string
}

variables "test_name" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}
