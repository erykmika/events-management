# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.1"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# ALB Module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "${var.project}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  # Security group
  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "frontend"
      }

      rules = {
        backend = {
          priority = 10
          actions = [{
            type             = "forward"
            target_group_key = "backend"
          }]
          conditions = [{
            path_pattern = {
              values = ["/api/*"]
            }
          }]
        }
      }
    }
  }

  target_groups = {
    frontend = {
      name_prefix                       = "fe-"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "ip"
      deregistration_delay              = 30
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      create_attachment = false
    }

    backend = {
      name_prefix                       = "be-"
      protocol                          = "HTTP"
      port                              = 8000
      target_type                       = "ip"
      deregistration_delay              = 30
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/docs"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      create_attachment = false
    }
  }
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  project     = var.project
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  alb_security_group_id     = module.alb.security_group_id
  backend_target_group_arn  = module.alb.target_groups["backend"].arn
  frontend_target_group_arn = module.alb.target_groups["frontend"].arn

  backend_ecr_url  = module.ecr.backend_repository_url
  frontend_ecr_url = module.ecr.frontend_repository_url

  desired_count_backend  = var.desired_count_backend
  desired_count_frontend = var.desired_count_frontend

  iam_execution_role_arn = var.iam_role_arn

  database_url = module.rds.database_url

  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_app_client_id = module.cognito.app_client_id
  cognito_jwks_url      = module.cognito.jwks_url

  alb_dns_name = module.alb.dns_name

  s3_assets_bucket = module.s3.assets_bucket_name
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project     = var.project
  environment = var.environment

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # Reference ECS SG
  ecs_tasks_security_group_id = module.ecs.ecs_tasks_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  db_instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
}

module "cognito" {
  source = "./modules/cognito"

  aws_region            = var.aws_region
  project               = var.project
  default_user_password = var.default_user_password
}

module "s3" {
  source = "./modules/lambda_s3"
  project = var.project
  iam_role_arn = var.iam_role_arn
}