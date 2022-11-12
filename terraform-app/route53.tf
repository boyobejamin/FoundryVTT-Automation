data "aws_route53_zone" "selected" {
  name = var.domain
}

resource "aws_route53_record" "vtt" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.fqdn
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_lb.external.dns_name]
}
