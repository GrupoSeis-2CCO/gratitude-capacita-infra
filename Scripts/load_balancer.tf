# # Load Balancer
# resource "aws_lb" "gratitude_alb" {
#   name               = "gratitude-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.sg_publica_gratitude.id]
#   subnets            = [
#     aws_subnet.subrede_publica1_gratitude.id,
#     aws_subnet.subrede_publica2_gratitude.id
#   ]
# }

# # Target Group
# resource "aws_lb_target_group" "gratitude_tg" {
#   name     = "gratitude-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc_cco_gratitude.id
#   target_type = "instance"
# }

# # Listener
# resource "aws_lb_listener" "gratitude_listener" {
#   load_balancer_arn = aws_lb.gratitude_alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.gratitude_tg.arn
#   }
# }

# # Attach EC2 instances to Target Group
# resource "aws_lb_target_group_attachment" "gratitude_ec2_publica_1" {
#   target_group_arn = aws_lb_target_group.gratitude_tg.arn
#   target_id        = aws_instance.ec2_publica_gratitude_1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "gratitude_ec2_publica_2" {
#   target_group_arn = aws_lb_target_group.gratitude_tg.arn
#   target_id        = aws_instance.ec2_publica_gratitude_2.id
#   port             = 80
# }
