variable "project" {
  description = "Project name"
  type        = string
}

variable "iam_role_arn" {
  type        = string
}

variable "s3_assets_bucket" {
  description = "S3 bucket name for assets"
  type        = string
}

variable "minio_endpoint" {
  description = "MinIO endpoint"
  type        = string
}

variable "minio_access_key" {
  description = "MinIO access key"
  type        = string
}

variable "minio_secret_access_key" {
  description = "MinIO secret access key"
  type        = string
}