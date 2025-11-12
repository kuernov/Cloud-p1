# Tworzenie repozytoriów dla obrazów Dockera
# Backend i frontend będą potem pobierać te obrazy przy starcie ECS-a.

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project}-backend-${var.env}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project}-frontend-${var.env}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true

}