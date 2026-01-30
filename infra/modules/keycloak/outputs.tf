output "keycloak_service_name" {
  description = "Keycloak ECS service name"
  value       = aws_ecs_service.keycloak.name
}

output "keycloak_task_definition_arn" {
  description = "Keycloak task definition ARN"
  value       = aws_ecs_task_definition.keycloak.arn
}
