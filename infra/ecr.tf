resource "aws_ecr_repository" "frontend" {
  name = "${var.project}-frontend"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}

resource "aws_ecr_repository" "backend" {
  name = "${var.project}-backend"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}

output "frontend_ecr_url" { value = aws_ecr_repository.frontend.repository_url }
output "backend_ecr_url"  { value = aws_ecr_repository.backend.repository_url }
