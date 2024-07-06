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
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    container_name   = "flask-api-container"
    container_port   = 8000
    target_group_arn = aws_lb_target_group.ecs_rest_api_tg.arn

  }
}

# Create an ECS task definition.
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "ecs-flask-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn
  # container definitions describes the configurations for the task
  container_definitions = jsonencode(
    [
      {
        "name" : "flask-api-container",
        "image" : "${data.aws_ecr_repository.ecr.repository_url}:latest",
        "essential" : true,
        "networkMode" : "awsvpc",
        "portMappings" : [
          {
            container_port = 8000
            host_port      = 8000
            protocol       = "tcp"
          }
        ]
        # "healthCheck" : {
        #   "command" : ["CMD-SHELL", "curl -f http://localhost:8000/ || exit 1"],
        #   "interval" : 30,
        #   "timeout" : 5,
        #   "startPeriod" : 10,
        #   "retries" : 3
        # }
      }
    ]
  )

}
