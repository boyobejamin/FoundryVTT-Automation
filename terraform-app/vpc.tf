data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Default VPC"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "lb" {
  name = "${var.project}-${var.bootstrap}-lb-sg"
}

resource "aws_security_group" "ecs" {
  name        = "${var.project}-${var.environment}-ecs-sg"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description     = "Allow HTTPS inbound"
    from_port       = 30000
    to_port         = 30000
    protocol        = "tcp"
    security_groups = [data.aws_security_group.lb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "efs" {
  name        = "${var.project}-${var.environment}-efs-sg"
  description = "Allow NFS inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description     = "Allow NFS inbound"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ingress {
    description     = "Allow NFS inbound"
    from_port       = 2999
    to_port         = 2999
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}