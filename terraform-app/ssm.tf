resource "random_password" "this" {
  count   = 1
  length  = 30
  special = false
  upper   = true
  numeric = true
}

resource "aws_ssm_parameter" "foundry_admin_password" {
  name = "/app/${var.project}/${var.environment}/admin/password"
  type = "SecureString"

  value = random_password.this[0].result
}