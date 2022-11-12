
resource "aws_ssm_parameter" "cert" {
  name      = "/app/${var.project}/${var.environment}/TLS/cert"
  type      = "SecureString"
  overwrite = true
  value     = base64encode(acme_certificate.certificate.certificate_pem)
}

resource "aws_ssm_parameter" "chain" {
  name      = "/app/${var.project}/${var.environment}/TLS/chain"
  type      = "SecureString"
  tier      = "Advanced"
  overwrite = true
  value     = base64encode(acme_certificate.certificate.issuer_pem)
}

resource "aws_ssm_parameter" "privkey" {
  name      = "/app/${var.project}/${var.environment}/TLS/privkey"
  type      = "SecureString"
  overwrite = true
  value     = base64encode(acme_certificate.certificate.private_key_pem)
}