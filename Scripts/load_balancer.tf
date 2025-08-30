# Segunda subnet pública em outra zona de disponibilidade
resource "aws_subnet" "subrede_publica2_gratitude" {
  vpc_id                  = aws_vpc.vpc_cco_gratitude.id
  cidr_block              = "10.0.1.0/25"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subrede_publica2_gratitude"
  }
}

# Load Balancer com duas subnets públicas
resource "aws_lb" "gratitude_alb" {
  name               = "gratitude-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_publica_gratitude.id]
  subnets            = [aws_subnet.subrede_publica_gratitude.id, aws_subnet.subrede_publica2_gratitude.id]
  tags = {
    Name = "gratitude-alb"
  }
}

resource "aws_lb_target_group" "gratitude_tg" {
  name     = "gratitude-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_cco_gratitude.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "gratitude-tg"
  }
}

resource "aws_lb_listener" "gratitude_listener" {
  load_balancer_arn = aws_lb.gratitude_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gratitude_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "gratitude_ec2_publica" {
  target_group_arn = aws_lb_target_group.gratitude_tg.arn
  target_id        = aws_instance.ec2_publica_gratitude.id
  port             = 80
}
