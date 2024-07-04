# Create the ECS cluster.
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "flask_cluster"
}

data "aws_ecr_repository" "ecr" {
  name = "flask-docker-app"
}

# Create the ECS service.
resource "aws_ecs_service" "service" {
  name            = "flask-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_capacity
  depends_on      = [aws_lb_listener.alb_listener]

  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id, aws_security_group.alb_sg.id]
  }
  load_balancer {
    container_name   = "flask-container"
    container_port   = 8000
    target_group_arn = aws_lb_target_group.ecs_rest_api_tg.arn
  }
}

# Create an ECS task definition.
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "ecs-flask-app"
  # container definitions describes the configurations for the task
  container_definitions = jsonencode(
    [
      {
        "name" : "flask-container",
        "image" : "${data.aws_ecr_repository.ecr.repository_url}:latest",
        "entryPoint" : []
        "essential" : true,
        "networkMode" : "awsvpc",
        "portMappings" : [
          {
            "containerPort" : 8000,
            "hostPort" : 8000,
          }
        ]
        "healthCheck" : {
          "command" : ["CMD-SHELL", "curl -f http://localhost:8000/ || exit 1"],
          "interval" : 30,
          "timeout" : 5,
          "startPeriod" : 10,
          "retries" : 3
        }
      }
    ]
  )
  #Fargate is used as opposed to EC2, so we do not need to manage the EC2 instances. Fargate is serveless
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn
}
