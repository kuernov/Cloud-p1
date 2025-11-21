########################################
# ECS Cluster
########################################
# Środowisko, które zarządza kontenerami
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  cluster_name = "${var.project}-cluster-${var.env}"
}

# #######################################
# ALB
# #######################################
# Load balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  name               = "${var.project}-alb-${var.env}"
  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  enable_deletion_protection = false
  security_groups = [aws_security_group.alb_sg.id]


  # Definicje target groups
  target_groups = {
    frontend = {
      name_prefix      = "fe-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "ip"
      health_check     = { 
        path = "/"
        interval            = 30    # Sprawdzaj co 30 sekund (nie 100)
        timeout             = 5     # Czekaj 5 sekund (nie 50)
        healthy_threshold   = 3     # Wystarczą 3 udane próby (nie 5)
        unhealthy_threshold = 2     # Wystarczą 2 nieudane próby (nie 3)
        matcher             = "200-399" 
        }
      create_attachment = false
    }
    backend = {
      name_prefix      = "be-"
      protocol         = "HTTP"
      port             = 8080
      target_type      = "ip"
      health_check     = { 
        path = "/actuator/health"
        interval            = 30    # Sprawdzaj co 30 sekund (nie 100)
        timeout             = 5     # Czekaj 5 sekund (nie 50)
        healthy_threshold   = 3     # Wystarczą 3 udane próby (nie 5)
        unhealthy_threshold = 2     # Wystarczą 2 nieudane próby (nie 3)
        matcher             = "200-399" } 
      create_attachment = false
    }
  }

  # Listener HTTP
  listeners = {
    http = {
      port            = 80
      protocol        = "HTTP"
      


  # Domyślna akcja — np. kieruj wszystko do frontendu
      forward = {
        target_group_key = "frontend"
      }


      rules = {
        api_rule = {
          priority = 1
          actions = [
            {
              forward = {
              target_group_key = "backend"
              }
            }
          ]
          conditions = [
            {
              path_pattern = { values = ["/api/*"] }
            }
          ]
        }
      }
    }
  }
}

########################################
# Backend ECS Service
########################################
module "ecs_service_backend" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "6.7.0"
  

  name        = "backend"
  cluster_arn = module.ecs_cluster.cluster_arn

  cpu           = 256
  memory        = 512
  desired_count = 1
  launch_type   = "FARGATE"

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.ecs_service.id]
  assign_public_ip   = false
  health_check_grace_period_seconds = 90
  load_balancer = {
      backend = {
        target_group_arn = module.alb.target_groups["backend"].arn
        container_name   = "backend"
        container_port   = 8080 
      }
  }

  volume = {
    "backend_tmp" = { # Klucz w Terraformie, może być dowolny
      name = "tomcat-tmp" # Nazwa, do której odwoła się kontener
    }
  }
  enable_execute_command = true


  

# Wyłącz tworzenie roli wykonawczej (Task Execution Role)
  create_task_exec_iam_role = false
  
  # Zamiast tego, użyj ARN roli 'LabRole'
  task_exec_iam_role_arn = data.aws_iam_role.lab_role.arn

  # Wyłącz tworzenie roli zadania (Task Role)
  create_tasks_iam_role = false
  
  # Zamiast tego, również użyj ARN roli 'LabRole'
  tasks_iam_role_arn = data.aws_iam_role.lab_role.arn


  container_definitions = {
    backend = {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [{
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
      }]
      # logConfiguration = {
      #   logDriver = "awslogs",
      #   options = {
      #     "awslogs-group"         = aws_cloudwatch_log_group.backend_logs.name
      #     "awslogs-region"        = var.aws_region
      #     "awslogs-stream-prefix" = "ecs-backend"
      #   }
      # }
environment = [
      {
        name  = "SPRING_DATASOURCE_URL"
        value = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/${var.db_name}"
      },
      {
        name  = "SPRING_DATASOURCE_USERNAME"
        value = var.db_username
      },
      {
        name  = "SPRING_DATASOURCE_PASSWORD"
        value = var.db_password
      },
      {
        name  = "S3_BUCKET"
        value = aws_s3_bucket.media.bucket
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "COGNITO_USER_POOL_ID"
        value = aws_cognito_user_pool.user_pool.id
      }
    ]
      mountPoints = [
        {
          sourceVolume  = "tomcat-tmp" # Musi pasować do 'name' z 'volume' powyżej
          containerPath = "/tmp"
          readOnly      = false # WAŻNE: 'false' oznacza, że jest zapisywalny
        }
      ]

      
    }
  }
}

########################################
# Frontend ECS Service
########################################
module "ecs_service_frontend" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "6.7.0"

  name        = "frontend"
  cluster_arn = module.ecs_cluster.cluster_arn

  # Rola LabRole (OK dla AWS Academy)
  create_task_exec_iam_role = false
  task_exec_iam_role_arn    = data.aws_iam_role.lab_role.arn
  create_tasks_iam_role     = false
  tasks_iam_role_arn        = data.aws_iam_role.lab_role.arn

  cpu           = 256
  memory        = 512
  desired_count = 1
  launch_type   = "FARGATE"

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.ecs_service.id]
  assign_public_ip   = false

  load_balancer = {
    frontend = {
      target_group_arn = module.alb.target_groups["frontend"].arn 
      container_name   = "frontend"
      container_port   = 80 
    }
  }
    enable_execute_command = true

  # Wolumeny dla Nginx (Bardzo dobrze, że to masz! Nginx tego potrzebuje na Fargate)
  volume = {
    "frontend_cache" = { name = "nginx-cache" },
    "frontend_run"   = { name = "nginx-run" },
    "frontend_tmp"   = { name = "nginx-tmp" }

  }

  container_definitions = {
    frontend = {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend.repository_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      # ### TO TRZEBA DODAĆ (Przekazanie danych z Terraform do Dockera) ###
      environment = [
        {
          name  = "COGNITO_REGION"
          value = var.aws_region
        },
        {
          name  = "COGNITO_USER_POOL_ID"
          value = aws_cognito_user_pool.user_pool.id # Upewnij się, że nazwa zasobu (my_pool) jest poprawna!
        },
        {
          name  = "COGNITO_APP_CLIENT_ID"
          value = aws_cognito_user_pool_client.app_client.id # Tutaj też sprawdź nazwę zasobu
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "nginx-cache"
          containerPath = "/var/cache/nginx"
          readOnly      = false
        },
        {
          sourceVolume  = "nginx-run"
          containerPath = "/var/run"
          readOnly      = false
        },
        {
          sourceVolume  = "nginx-tmp"
          containerPath = "/tmp"
          readOnly      = false
        }
      ]
    }
  }
}


