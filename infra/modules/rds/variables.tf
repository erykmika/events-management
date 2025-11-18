variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "ecs_tasks_security_group_id" {
  description = "Security group ID of ECS tasks that need to access the database"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "eventsdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgresadmin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "18"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}
