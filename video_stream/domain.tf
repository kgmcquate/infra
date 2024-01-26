data "aws_route53_zone" "primary" {
  name = local.domain
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "pulsar.${data.aws_route53_zone.primary.name}"
  type    = "A"
  ttl     = 300
  records = [module.video_stream_pulsar.public_ip]
}

data "aws_acm_certificate" "tls_cert" {
  domain      = local.domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# aws_acm_certificate.tls_cert.certificate

# aws_acm_certificate.tls_cert.certificate_chain

# Create an Application Load Balancer
resource "aws_lb" "linux-alb" {
  name               = "linux-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = [var.subnet_id]
  enable_deletion_protection = false
  enable_http2               = false
}

# Create a Load Balancer Target Group for HTTP
resource "aws_lb_target_group" "linux-alb-target-group-http" {  
  name     = "linux-alb-tg-http"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.video_stream_pulsar.v
  
  deregistration_delay = 60
  stickiness {
    type = "lb_cookie"
  }
#   health_check {
#     path                = "/"
#     port                = 8080
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     timeout             = 10
#     interval            = 30
#     matcher             = "200,301,302"
#   }
}

# Attach EC2 Instances to Application Load Balancer Target Group
resource "aws_alb_target_group_attachment" "linux-alb-target-group-http-attach" {
  target_group_arn = aws_lb_target_group.linux-alb-target-group-http.arn
  target_id        = module.video_stream_pulsar.id
  port             = 8080
}

resource "aws_lb_listener" "linux-alb-listener-http" {  
  depends_on = [
    aws_lb.linux-alb,
    aws_lb_target_group.linux-alb-target-group-http
  ]
  
  load_balancer_arn = aws_lb.linux-alb.arn
  port              = 8080
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = aws_lb_target_group.linux-alb-target-group-http.arn
    type             = "forward"  
  }
}


resource "aws_alb_listener" "linux-alb-listener-https" {
  load_balancer_arn = aws_lb.linux-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.tls_cert.arn
  default_action {
    target_group_arn = aws_lb_target_group.linux-alb-target-group-http.arn
    type = "forward"
  }
}