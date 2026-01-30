variable "project" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "iam_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "keycloak_target_group_arn" {
  description = "ALB target group ARN for Keycloak"
  type        = string
}

variable "keycloak_ecr_url" {
  type        = string
  default     = ""
}

variable "realm_json_b64" {
  description = "Base64-encoded Keycloak realm JSON to import"
  type        = string
}

variable "alb_dns_name" {
  description = "Public DNS name of the ALB used as Keycloak frontend hostname"
  type        = string
}
