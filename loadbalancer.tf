
#pour HTTPS
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       value  = dvo.resource_record_value
#       zone_id  = aws_lb.wordpress.zone_id # Remplacez par l'ID de zone de l'ELB  # Remplacez par votre ID de zone
#     }
#   }

#   zone_id = each.value.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.value]
#   ttl     = 60
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "projetweb.maysadevops.dns-dynamic.net"
#   validation_method = "DNS"

#   tags = {
#     Name = "projetweb-cert"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }
# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }


resource "aws_lb" "wordpress" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wordpress.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "wordpress-lb"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}
resource "aws_lb_target_group" "wordpress" {
  name     = "wordpress-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "wordpress-target-group"
  }
}
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.wordpress.arn
#   port              = 443
#   protocol          = "HTTPS"

#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.cert.arn

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.wordpress.arn
#   }
# }