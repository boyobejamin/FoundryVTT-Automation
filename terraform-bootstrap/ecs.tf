resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.environment}-cluster"
}