data "aws_lb" "external" {
  name = "${var.project}-${var.bootstrap}-lb"
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.external.arn
  port              = 443
}

resource "aws_lb_target_group" "foundry" {
  name        = "${var.project}-${var.environment}-foundry"
  port        = 30000
  protocol    = "HTTPS"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTPS"
    matcher             = "200-299"
    timeout             = "120"
    path                = "/api/status"
    unhealthy_threshold = "5"
  }
}


resource "aws_alb_listener_rule" "foundry_1" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foundry.arn
  }

  condition {
    http_request_method {
      values = ["GET", "POST", "PUT", "DELETE"]
    }
  }

  condition {
    host_header {
      values = [local.fqdn]
    }
  }
}

resource "aws_alb_listener_rule" "foundry_2" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foundry.arn
  }

  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }

  condition {
    host_header {
      values = [local.fqdn]
    }
  }
}
