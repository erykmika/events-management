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

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "database_url" {
  description = "Postgres RDS URL"
  type = string
}