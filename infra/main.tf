# Get current AWS account ID
data "aws_caller_identity" "current" {}

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
    all_minio = {
      from_port   = 9000
      to_port     = 9000
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_grafana = {
      from_port   = 3000
      to_port     = 3000
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_prometheus = {
      from_port   = 9090
      to_port     = 9090
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
        metrics = {
          priority = 11
          actions = [{
            type             = "forward"
            target_group_key = "backend"
          }]
          conditions = [{
            path_pattern = {
              values = ["/metrics"]
            }
          }]
        }
        keycloak = {
          priority = 20
          actions = [{
            type             = "forward"
            target_group_key = "keycloak"
          }]
          conditions = [{
            path_pattern = {
              values = ["/auth/*"]
            }
          }]
        }
      }
    }
    minio = {
      port     = 9000
      protocol = "HTTP"

      forward = {
        target_group_key = "minio"
      }
    }
    grafana = {
      port     = 3000
      protocol = "HTTP"

      forward = {
        target_group_key = "grafana"
      }
    }
    prometheus = {
      port     = 9090
      protocol = "HTTP"

      forward = {
        target_group_key = "prometheus"
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
        interval            = 20
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      create_attachment = false
    }

    minio = {
      name_prefix                       = "mi-"
      protocol                          = "HTTP"
      port                              = 9000
      target_type                       = "ip"
      deregistration_delay              = 30
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/minio/health/ready"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      create_attachment = false
    }

    grafana = {
      name_prefix                       = "gr-"
      protocol                          = "HTTP"
      port                              = 3000
      target_type                       = "ip"
      deregistration_delay              = 30
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      create_attachment = false
    }

    prometheus = {
      name_prefix                       = "pr-"
      protocol                          = "HTTP"
      port                              = 9090
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

    keycloak = {
      name_prefix                       = "kc-"
      protocol                          = "HTTP"
      port                              = 8080
      target_type                       = "ip"
      deregistration_delay              = 30
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/auth"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-499"
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

# Lambda
module "lambda" {
  source = "./modules/lambda"
  project                  = var.project
  iam_role_arn             = var.iam_role_arn
  s3_assets_bucket         = var.s3_assets_bucket
  minio_endpoint           = "${module.alb.dns_name}:9000"
  minio_access_key         = var.minio_access_key
  minio_secret_access_key  = var.minio_secret_access_key
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

  db_name     = var.db_name
  db_username = var.db_username

  keycloak_base_url     = "http://${module.alb.dns_name}/auth"
  keycloak_realm        = "events"
  keycloak_client_id    = "events-frontend"
  keycloak_jwks_url     = "http://${module.alb.dns_name}/auth/realms/events/protocol/openid-connect/certs"

  alb_dns_name = module.alb.dns_name

  minio_target_group_arn = module.alb.target_groups["minio"].arn

  grafana_target_group_arn    = module.alb.target_groups["grafana"].arn
  prometheus_target_group_arn = module.alb.target_groups["prometheus"].arn

  minio_access_key = var.minio_access_key
  minio_secret_access_key = var.minio_secret_access_key

  lambda_arn = module.lambda.lambda_function_arn

  db_password = var.db_password

  logging_level = "INFO"
}

module "keycloak" {
  source = "./modules/keycloak"

  project                    = var.project
  aws_region                 = var.aws_region
  cluster_id                 = module.ecs.cluster_id
  ecs_tasks_security_group_id= module.ecs.ecs_tasks_security_group_id
  private_subnets            = module.vpc.private_subnets
  iam_execution_role_arn     = var.iam_role_arn
  keycloak_target_group_arn  = module.alb.target_groups["keycloak"].arn
  realm_json_b64             = filebase64("${path.root}/keycloak/realm.json")
  alb_dns_name               = module.alb.dns_name
}