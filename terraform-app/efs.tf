resource "aws_efs_file_system" "foundry" {
  creation_token = "${var.project}-${var.environment}-foundry-data"
}

resource "aws_efs_mount_target" "foundry" {
  for_each        = toset(data.aws_subnets.selected.ids)
  file_system_id  = aws_efs_file_system.foundry.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_backup_policy" "foundry" {
  file_system_id = aws_efs_file_system.foundry.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_access_point" "foundry" {
  file_system_id = aws_efs_file_system.foundry.id

  posix_user {
    uid            = 1000
    gid            = 1000
    secondary_gids = ["0", "1000"]
  }

  root_directory {
    path = "/opt/foundry-data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
  }
}

resource "aws_efs_file_system_policy" "foundry" {
  file_system_id = aws_efs_file_system.foundry.id

  bypass_policy_lockout_safety_check = true

  policy = data.aws_iam_policy_document.efs_foundry.json
}

data "aws_iam_policy_document" "efs_foundry" {
  statement {
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]

    # condition {
    #   test  = "Bool"
    #   variable = "aws:SecureTransport"
    #   values = ["true"]
    # }

    # condition {
    #   test  = "Bool"
    #   variable = "elasticfilesystem:AccessedViaMountTarget"
    #   values = ["true"]
    # }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    #resources = {for k, v in aws_efs_mount_target.foundry : k => v.arn}
    resources = ["*"]
  }

  statement {
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]

    # condition {
    #   test  = "Bool"
    #   variable = "aws:SecureTransport"
    #   values = ["true"]
    # }

    # condition {
    #   test  = "StringEquals"
    #   variable = "elasticfilesystem:AccessPointArn"
    #   values = [aws_efs_access_point.foundry.arn]
    # }

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ecs_task_role.arn]
    }

    resources = [aws_efs_file_system.foundry.arn]
  }
}