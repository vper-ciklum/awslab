variable "AWS_ACCESS_KEY" {
  default = ""
}

variable "AWS_SECRET_KEY" {
  default = ""
}

variable "namespace" {
  description = "For the proper naming"
  default     = "awslab"
  type        = string
}

variable "region" {
  description = "AWS region to be used"
  default     = "us-east-2"
  type        = string
}