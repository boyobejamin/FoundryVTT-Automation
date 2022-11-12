provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      Owner       = var.owner
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }
  }
  backend "s3" {
    encrypt = true
    key     = "app/terraform.tfstate"
  }
}

# module "vpc" {
#   source      = "./modules/vpc"
#   aws_region  = var.aws_region
#   project     = var.project
#   environment = var.environment
# }

# module "iam" {
#   source        = "./modules/iam"
#   project       = var.project
#   environment   = var.environment
#   aws_partition = var.aws_partition
# }

locals {
  fqdn = "${var.environment}.vtt.${var.domain}"
  url = local.fqdn
}

data "aws_ecr_repository" "foundry" {
  name = "${var.project}-${var.environment}-foundry"
}

data "aws_ssm_parameter" "certificate" {
  name            = "/app/${var.project}/${var.environment}/TLS/cert"
  with_decryption = true
}

data "aws_ssm_parameter" "privkey" {
  name            = "/app/${var.project}/${var.environment}/TLS/privkey"
  with_decryption = true
}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}

data "aws_iam_server_certificate" "foundry" {
  name_prefix = "${var.project}-${var.environment}-foundry-certificate"
  latest      = true
}