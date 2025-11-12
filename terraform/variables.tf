variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "myapp"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "postgres123"
}

variable "db_name" {
  type    = string
  default = "myappdb"
}

variable "create_ecs_services" {
  description = "Przełącznik (true/false) do tworzenia serwisów ECS. Ustaw na true DOPIERO po wrzuceniu obrazów do ECR."
  type        = bool
  default     = false
}