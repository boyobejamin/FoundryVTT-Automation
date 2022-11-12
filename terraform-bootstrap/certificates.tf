
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.email
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.domain
  subject_alternative_names = ["*.vtt.${var.domain}"]

  dns_challenge {
    provider = "route53"
  }
}

resource "aws_iam_server_certificate" "primary" {
  name_prefix       = "${var.project}-${var.environment}-foundry-certificate"
  private_key       = acme_certificate.certificate.private_key_pem
  certificate_body  = acme_certificate.certificate.certificate_pem
  certificate_chain = acme_certificate.certificate.issuer_pem

  lifecycle {
    create_before_destroy = true
  }
}