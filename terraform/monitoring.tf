# resource "aws_cloudwatch_log_group" "backend_logs" {
#   name              = "/ecs/${var.project}/backend-${var.env}"
#   retention_in_days = 7
# }

# resource "aws_sns_topic_subscription" "email_subscription" {
#   topic_arn = aws_sns_topic.default_alerts.arn
#   protocol  = "email"
#   endpoint  = "264271@student.pwr.edu.pl"
# }

# resource "aws_sns_topic" "default_alerts" {
#   name = "${var.project}-alerts-${var.env}"
# }

# ########################################
# # 1. Alert: Wysokie CPU na Serwisie ECS
# ########################################
# resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
#     count = var.create_ecs_services ? 1 : 0
#   alarm_name          = "${var.project}-ecs-cpu-high-${var.env}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = "60" 
#   statistic           = "Average"
#   threshold           = "80"
#   alarm_description   = "CPU serwisu ECS jest powyżej 80% przez 3 minuty"
  
#   dimensions = {
#     ClusterName = module.ecs_cluster.cluster_name
#     ServiceName = module.ecs_service_backend.name  
#     }
  
#   alarm_actions = [aws_sns_topic.default_alerts.arn]
#   ok_actions    = [aws_sns_topic.default_alerts.arn]
# }

# ########################################
# # 2. Alert: Błędy 5xx (Server Errors) na ALB
# ########################################
# resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
#   alarm_name          = "${var.project}-alb-5xx-errors-${var.env}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "HTTPCode_Target_5XX_Count"
#   namespace           = "AWS/ApplicationELB"
#   period              = "300"
#   statistic           = "Sum"
#   threshold           = "5"
#   alarm_description   = "ALB zanotował 5 lub więcej błędów 5xx w ciągu 5 minut"

#   # DOSTOSUJ NAZWĘ SWOJEGO ALB:
#   dimensions = {
#     LoadBalancer = split("/", module.alb.arn)[1]  
# }

#   alarm_actions = [aws_sns_topic.default_alerts.arn]
#   ok_actions    = [aws_sns_topic.default_alerts.arn]
# }


# resource "aws_cloudwatch_dashboard" "main_dashboard" {
#   dashboard_name = "${var.project}-dashboard-${var.env}"

#   dashboard_body = jsonencode({
#     widgets = concat(

#       # === WIDGET 1: ECS (WARUNKOWY) ===
#       # Używamy operatora trójargumentowego: (warunek ? [lista_jeśli_prawda] : [lista_jeśli_fałsz])
#       var.create_ecs_services ? [
#         {
#           type = "metric",
#           x = 0, y = 0, width = 12, height = 6,
#           properties = {
#             metrics = [
#               ["AWS/ECS", "CPUUtilization", "ClusterName", module.ecs_cluster.cluster_name, "ServiceName", module.ecs_service_backend[0].name],
#               ["AWS/ECS", "MemoryUtilization", "ClusterName", module.ecs_cluster.cluster_name, "ServiceName", module.ecs_service_backend[0].name]
#             ],
#             period = 300, stat = "Average", region = "us-east-1", title = "ECS Service (Backend) - CPU & Memory"
#           }
#         }
#       ] : [], # Jeśli warunek jest fałszywy, dodajemy pustą listę

#       # === WIDGET 2: ALB (STAŁY) ===
#       [
#         {
#           type = "metric",
#           x = 12, y = 0, width = 12, height = 6,
#           properties = {
#             metrics = [
#               ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", split("/", module.alb.arn)[1]],
#               ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", split("/", module.alb.arn)[1], { stat = "Sum" }]
#             ],
#             period = 300, stat = "Sum", region = "us-east-1", title = "ALB - Requests & 5xx Errors"
#           }
#         }
#       ],

#       # === WIDGET 3: RDS (STAŁY) ===
#       # Zakładam, że RDS nie jest warunkowy
#       [
#         {
#           type = "metric",
#           x = 0, y = 6, width = 12, height = 6,
#           properties = {
#             metrics = [
#               ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.postgres.id],
#               ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.postgres.id]
#             ],
#             period = 300, stat = "Average", region = "us-east-1", title = "RDS Database - CPU & Connections"
#           }
#         }
#       ]
#     ) 
#   })
# }