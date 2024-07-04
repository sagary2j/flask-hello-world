
# Create the Application Load Balancer.
resource "aws_lb" "main" {
  name                       = "flask-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ecs_sg.id]
  subnets                    = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  idle_timeout               = 30
  enable_deletion_protection = false
}

# Create the ALB target group.
resource "aws_lb_target_group" "ecs_rest_api_tg" {
  name        = "ecs-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }
}

# Create the ALB listener.
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_rest_api_tg.arn
    type             = "forward"
  }
}
