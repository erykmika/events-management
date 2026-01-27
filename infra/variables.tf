variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "events-management"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
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

variable "iam_role_arn" {
  description = "ARN of the IAM role"
  type        = string
  default     = "arn:aws:iam::ACCOUNT_ID:role/LabRole"
}

# RDS Variables
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
  description = "Database master password (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
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


variable "default_user_password" {
  description = "Default user password"
  type = string
  sensitive = true
}

variable "account_id" {
  description = "AWS account ID"
  type = string
}

variable "minio_access_key" {
  description = "Minio access key"
  type = string
  default = "minioadmin"
}

variable "minio_secret_access_key" {
  description = "Minio secret access key"
  type = string
  default = "minioadmin"
}