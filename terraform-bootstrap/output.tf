output "certificate" {
  value = {
    id   = aws_iam_server_certificate.primary.name
    name = aws_iam_server_certificate.primary.name
    san  = ["vtt.${var.domain}"]
  }
}

output "ecr" {
  value = {
    FoundryVTT = aws_ecr_repository.foundry.repository_url
  }
}

output "ecs" {
  value = {
    cluster_arn = aws_ecs_cluster.this.arn
    cluster_id  = aws_ecs_cluster.this.id
  }
}

output "lb" {
  value = {
    id       = aws_lb.external.id
    arn      = aws_lb.external.arn
    dns_name = aws_lb.external.dns_name
  }
}



output "terraform_backend" {
  value = {
    dynamodb = aws_dynamodb_table.terraform_locks.name
    s3       = aws_s3_bucket.terraform_states.arn
  }
}
