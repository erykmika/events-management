variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "backend_target_group_arn" {
  description = "Backend target group ARN"
  type        = string
}

variable "frontend_target_group_arn" {
  description = "Frontend target group ARN"
  type        = string
}

variable "backend_ecr_url" {
  description = "Backend ECR repository URL"
  type        = string
}

variable "frontend_ecr_url" {
  description = "Frontend ECR repository URL"
  type        = string
}

variable "desired_count_backend" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 1
}

variable "desired_count_frontend" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 1
}

variable "backend_cpu" {
  description = "CPU units for backend task"
  type        = string
  default     = "512"
}

variable "backend_memory" {
  description = "Memory for backend task"
  type        = string
  default     = "1024"
}

variable "frontend_cpu" {
  description = "CPU units for frontend task"
  type        = string
  default     = "256"
}

variable "frontend_memory" {
  description = "Memory for frontend task"
  type        = string
  default     = "512"
}

variable "iam_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "db_name" {
  description = "Postgres database name"
  type        = string
}

variable "db_username" {
  description = "Postgres database username"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito user pool ID"
  type        = string
}

variable "cognito_app_client_id" {
  description = "Cognito app client ID"
  type        = string
}

variable "cognito_jwks_url" {
  description = "Cognito JWKS URL"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "minio_target_group_arn" {
  description = "MinIO target group ARN"
  type        = string
}

variable "minio_access_key" {
  description = "Minio access key"
  type = string
}

variable "minio_secret_access_key" {
  description = "Minio secret access key"
  type = string
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to process S3 events"
  type        = string
  default     = ""
}

variable "db_password" {
  type = string
}

variable "logging_level" {
  type = string
  description = "logging level for FastAPI backend"
}
