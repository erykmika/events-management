variable "project" {
  description = "Project name"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "image_uri" {
  description = "Lambda image URI"
  type = string
}