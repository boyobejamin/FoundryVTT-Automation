output "AWS" {
  value = {
    ecr = {
      FoundryVTT = data.aws_ecr_repository.foundry.repository_url
    }

    ecs = {
      cluster_arn = data.aws_ecs_cluster.this.arn
      cluster_id  = data.aws_ecs_cluster.this.id
    }

    s3      = aws_s3_bucket.foundry_storage.arn
    subnets = data.aws_subnets.selected.ids
    vpc = {
      vpc_id  = data.aws_vpc.selected.id
      tenancy = data.aws_vpc.selected.instance_tenancy
    }
  }
}

output "route53" {
  value = {
    arn  = data.aws_route53_zone.selected.arn
    name = aws_route53_record.vtt.name
    fqdn = aws_route53_record.vtt.fqdn
  }
}

output "Foundry_URL" {
  value = local.url
}

output "Foundry_Admin_Password" {
  sensitive = true
  value     = resource.aws_ssm_parameter.foundry_admin_password.value
}