variable "logs_bucket" {
  type = string
}

variable "logs_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "test_name" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}
