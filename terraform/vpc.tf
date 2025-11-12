########################################
# VPC
########################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "${var.project}-vpc-${var.env}"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

########################################
# ALB Security Group (public)
########################################
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg-${var.env}"
  description = "ALB SG: inbound from Internet, outbound to ECS"
  vpc_id      = module.vpc.vpc_id

  # Ingress z Internetu
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress → precyzyjnie do ECS na portach 80 (frontend) i 8080 (backend)
  egress {
    description     = "Allow ALB to reach ECS frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    description     = "Allow ALB to reach ECS backend"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  tags = {
    Name = "${var.project}-alb-sg-${var.env}"
  }
}

########################################
# ECS Security Group (private)
########################################
resource "aws_security_group" "ecs_service" {
  name        = "${var.project}-ecs-service-sg-${var.env}"
  description = "Allow inbound from ALB, outbound to RDS or Internet"
  vpc_id      = module.vpc.vpc_id

  # Tymczasowo bez ingress, dodamy niżej
  egress {
    description = "Allow outbound to RDS and Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-ecs-service-sg-${var.env}"
  }
}



# ECS → ALB (inbound)
resource "aws_security_group_rule" "ecs_from_alb_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ecs_service.id
  description              = "Allow HTTP from ALB to ECS"
}

resource "aws_security_group_rule" "ecs_from_alb_backend" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ecs_service.id
  description              = "Allow backend traffic from ALB to ECS"
}

########################################
# ECS → RDS
########################################
resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service.id
  security_group_id        = aws_security_group.rds_sg.id
  description              = "Allow ECS tasks to connect to RDS"
}
