resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project}-db-subnet-${var.env}"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg-${var.env}"
  description = "Allow PostgreSQL access from ECS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # Zezwól na ruch z dowolnego miejsca w naszych prywatnych podsieciach
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Tworzy instancje bazy danych
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project}-db-${var.env}"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  deletion_protection    = false
}

