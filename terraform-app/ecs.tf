data "aws_ecs_cluster" "this" {
  cluster_name = "${var.project}-${var.bootstrap}-cluster"
}

resource "aws_ecs_task_definition" "vtt" {
  family                   = "${var.project}-${var.environment}-vtt"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = 2048
  memory                   = 4096

  container_definitions = jsonencode([
    {
      name   = "vtt"
      image  = "${data.aws_ecr_repository.foundry.repository_url}:latest"
      cpu    = 2
      memory = 4096
      mountPoints = [
        {
          containerPath = "/opt/foundry-data",
          sourceVolume  = "foundry-storage"
        }
      ]
      portMappings = [
        {
          containerPort = 30000
          hostPort      = 30000
        }
      ]
      environment = [
        {
          name  = "AWS_REGION",
          value = var.aws_region
        },
        {
          name  = "ENVIRONMENT",
          value = var.environment
        },
        {
          name  = "PROJECT",
          value = var.project
        },
        {
          name  = "FOUNDRY_HOSTNAME",
          value = local.fqdn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : "/${var.project}/${var.environment}/logs"
          "awslogs-region" : "${var.aws_region}"
          "awslogs-stream-prefix" : "${var.project}-${var.environment}-vtt"
        }
      }
    }
  ])

  volume {
    name = "foundry-storage"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.foundry.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.foundry.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "vtt" {
  name                 = "${var.project}-${var.environment}-vtt-service"
  cluster              = data.aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.vtt.arn
  launch_type          = "FARGATE"
  desired_count        = 1
  force_new_deployment = true

  enable_execute_command = true

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = data.aws_subnets.selected.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.foundry.arn
    container_port   = 30000
    container_name   = "vtt"
  }
}
