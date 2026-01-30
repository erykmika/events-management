# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project}-backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.project}-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "minio" {
  name              = "/ecs/${var.project}-minio"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "postgres_db" {
  name              = "/ecs/${var.project}-postgres_db"
  retention_in_days = 7
}

# SG for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = var.iam_execution_role_arn
  task_role_arn            = var.iam_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.backend_ecr_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "ENVIRONMENT", value = var.environment },
        { name = "LOGGING_LEVEL", value = var.logging_level },
        { name = "DATABASE_URL", value = "postgresql://${var.db_username}:${var.db_password}@127.0.0.1:5432/${var.db_name}" },
        { name = "KEYCLOAK_CLIENT_ID", value = var.keycloak_client_id },
        { name = "KEYCLOAK_JWKS_URL", value = var.keycloak_jwks_url },
        { name = "S3_ASSETS_BUCKET", value = "eventsassets" },
        { name = "MINIO_ENDPOINT", value = "${var.alb_dns_name}:9000" },
        { name = "MINIO_ACCESS_KEY", value = var.minio_access_key },
        { name = "MINIO_SECRET_ACCESS_KEY", value = var.minio_secret_access_key },
        { name = "LAMBDA_ARN", value = var.lambda_arn },
        { name = "AWS_REGION", value = var.aws_region },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.id
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    },
    {
      name      = "postgres"
      image     = "docker.io/postgres:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "POSTGRES_DB", value = var.db_name },
        { name = "POSTGRES_USER", value = var.db_username },
        { name = "POSTGRES_PASSWORD", value = var.db_password },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.postgres_db.id
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "postgres_db"
        }
      }
    }
  ])
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = var.iam_execution_role_arn
  task_role_arn            = var.iam_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.frontend_ecr_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "API_URL", value = "http://${var.alb_dns_name}/api" },
        { name = "KEYCLOAK_BASE_URL", value = var.keycloak_base_url },
        { name = "KEYCLOAK_REALM", value = var.keycloak_realm },
        { name = "KEYCLOAK_CLIENT_ID", value = var.keycloak_client_id }
      ]


      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.id
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
    }
  ])
}

# MinIO Task Definition
resource "aws_ecs_task_definition" "minio" {
  family                   = "${var.project}-minio"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.iam_execution_role_arn
  task_role_arn            = var.iam_execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "minio"
      image = "minio/minio:latest"
      essential = true

      command = ["minio", "server", "/data", "--console-address", ":9001"]

      portMappings = [
        {
          containerPort = 9000
          protocol      = "tcp"
        },
        {
          containerPort = 9001
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "MINIO_ROOT_USER", value = "minioadmin" },
        { name = "MINIO_ROOT_PASSWORD", value = "minioadmin" },
        { name = "MINIO_NOTIFY_WEBHOOK_ENABLE_eventsassets", value = "on" },
        { name = "MINIO_NOTIFY_WEBHOOK_ENDPOINT_eventsassets", value = "http://${var.alb_dns_name}/api/minio/webhook" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.minio.id
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "minio"
        }
      }
    },
  ])
}

# Backend ECS Service
resource "aws_ecs_service" "backend" {
  name            = "${var.project}-backend-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count_backend
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 8000
  }
}

# Frontend ECS Service
resource "aws_ecs_service" "frontend" {
  name            = "${var.project}-frontend-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.desired_count_frontend
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }
}

# MinIO ECS Service
resource "aws_ecs_service" "minio" {
  name            = "${var.project}-minio-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.minio.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.minio_target_group_arn
    container_name   = "minio"
    container_port   = 9000
  }
}


# Postgres service
