# CloudWatch Log Group for Keycloak
resource "aws_cloudwatch_log_group" "keycloak" {
  name              = "/ecs/${var.project}-keycloak"
  retention_in_days = 7
}

# Keycloak Task Definition
resource "aws_ecs_task_definition" "keycloak" {
  family                   = "${var.project}-keycloak"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.iam_execution_role_arn
  task_role_arn            = var.iam_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "keycloak"
      image     = "quay.io/keycloak/keycloak:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "KEYCLOAK_ADMIN", value = "admin" },
        { name = "KEYCLOAK_ADMIN_PASSWORD", value = "admin" },
        { name = "KC_HTTP_ENABLED", value = "true" },
        { name = "KC_HTTP_RELATIVE_PATH", value = "/auth" },
        { name = "KC_PROXY", value = "edge" },
        { name = "KC_HOSTNAME", value = var.alb_dns_name },
        { name = "KC_HOSTNAME_STRICT", value = "false" },
        { name = "KC_HOSTNAME_STRICT_HTTPS", value = "false" },
        { name = "REALM_JSON_B64", value = var.realm_json_b64 }
      ]
      entryPoint = ["/bin/sh", "-c"]
      command    = [
        "mkdir -p /opt/keycloak/data/import && echo $REALM_JSON_B64 | base64 -d > /opt/keycloak/data/import/realm.json && /opt/keycloak/bin/kc.sh start --import-realm"
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "exit 0"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.keycloak.id,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "keycloak"
        }
      }
    }
  ])
}

# Keycloak ECS Service
resource "aws_ecs_service" "keycloak" {
  name            = "${var.project}-keycloak-svc"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.keycloak.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_tasks_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.keycloak_target_group_arn
    container_name   = "keycloak"
    container_port   = 8080
  }
}
