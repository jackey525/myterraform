
variable "region" {
  description = "The region which AWS resources are located in"
  type        = string
  default     = "ap-northeast-1"
}

variable "ami_name" {
  default = "php-web-2020-05-31"
}