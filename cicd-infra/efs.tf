############## jenkins efs ##########################
resource "aws_efs_file_system" "jenkins-efs" {
  creation_token = "jenkins-efs"
  encrypted      = true
  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_file_system_policy" "jenkins-efs-policy" {
  file_system_id = aws_efs_file_system.jenkins-efs.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "EFSPolicy",
  "Statement": [
    {
      "Sid": "DeleteProtection",
      "Action": [
        "elasticfilesystem:DeleteFileSystem"
      ],
      "Effect": "Deny",
      "Resource": "${aws_efs_file_system.jenkins-efs.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    },
    {
      "Sid": "AllowOtherActions",
      "Action": [
        "elasticfilesystem:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_efs_file_system.jenkins-efs.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_efs_backup_policy" "jenkins-efs-backup-policy" {
  file_system_id = aws_efs_file_system.jenkins-efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_security_group" "efs-sg" {
  name        = "efs-sg"
  description = "used for security of efs mount points"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    protocol    = "tcp"
    to_port     = 2049
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
}

resource "aws_efs_mount_target" "jenkins-efs-mount-1" {
  file_system_id  = aws_efs_file_system.jenkins-efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "jenkins-efs-mount-2" {
  file_system_id  = aws_efs_file_system.jenkins-efs.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "jenkins-efs-mount-3" {
  file_system_id  = aws_efs_file_system.jenkins-efs.id
  subnet_id       = module.vpc.private_subnets[2]
  security_groups = [aws_security_group.efs-sg.id]
}


############## nexus efs ##########################

resource "aws_efs_file_system" "nexus-efs" {
  creation_token = "nexus-efs"
  encrypted      = true
  tags = {
    Name = "nexus-efs"
  }
}

resource "aws_efs_file_system_policy" "nexus-efs-policy" {
  file_system_id = aws_efs_file_system.nexus-efs.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "EFSPolicy",
  "Statement": [
    {
      "Sid": "DeleteProtection",
      "Action": [
        "elasticfilesystem:DeleteFileSystem"
      ],
      "Effect": "Deny",
      "Resource": "${aws_efs_file_system.nexus-efs.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    },
    {
      "Sid": "AllowOtherActions",
      "Action": [
        "elasticfilesystem:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_efs_file_system.nexus-efs.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_efs_backup_policy" "nexus-efs-backup-policy" {
  file_system_id = aws_efs_file_system.nexus-efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "nexus-efs-mount-1" {
  file_system_id  = aws_efs_file_system.nexus-efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "nexus-efs-mount-2" {
  file_system_id  = aws_efs_file_system.nexus-efs.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "nexus-efs-mount-3" {
  file_system_id  = aws_efs_file_system.nexus-efs.id
  subnet_id       = module.vpc.private_subnets[2]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_kms_key" "nexus-efs-backup-key" {
  description = "nexus-efs-backup-key"
}

resource "aws_backup_vault" "nexus-efs-vault" {
  name        = "nexus-efs-vault"
  kms_key_arn = aws_kms_key.nexus-efs-backup-key.arn
}

resource "aws_backup_plan" "nexus-efs-backup-plan" {
  name = aws_efs_backup_policy.nexus-efs-backup-policy.id

  rule {
    rule_name         = "nexus_efs_backup_rule"
    target_vault_name = aws_backup_vault.nexus-efs-vault.name
    schedule          = "cron(0 */4 * * ? *)"
    lifecycle {
      delete_after = 15
    }
  }

}

resource "aws_iam_role" "nexus-efs-backup-iam-role" {
  name               = "nexus-efs-backup-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nexus-efs-backup-iam-policy-attachement" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.nexus-efs-backup-iam-role.name
}

resource "aws_backup_selection" "nexus-efs-backup-selection" {
  iam_role_arn = aws_iam_role.nexus-efs-backup-iam-role.arn
  name         = "nexus_efs_backup_selection"
  plan_id      = aws_backup_plan.nexus-efs-backup-plan.id

  resources = [
    aws_efs_file_system.nexus-efs.arn,
  ]
}

############## sonarqube efs ##########################

resource "aws_efs_file_system" "sonar-efs" {
  creation_token = "sonar-efs"
  encrypted      = true
  tags = {
    Name = "sonar-efs"
  }
}

resource "aws_efs_file_system_policy" "sonar-efs-policy" {
  file_system_id = aws_efs_file_system.sonar-efs.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "EFSPolicy",
  "Statement": [
    {
      "Sid": "DeleteProtection",
      "Action": [
        "elasticfilesystem:DeleteFileSystem"
      ],
      "Effect": "Deny",
      "Resource": "${aws_efs_file_system.sonar-efs.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    },
    {
      "Sid": "AllowOtherActions",
      "Action": [
        "elasticfilesystem:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_efs_file_system.sonar-efs.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_efs_backup_policy" "sonar-efs-backup-policy" {
  file_system_id = aws_efs_file_system.sonar-efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "sonar-efs-mount-1" {
  file_system_id  = aws_efs_file_system.sonar-efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "sonar-efs-mount-2" {
  file_system_id  = aws_efs_file_system.sonar-efs.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "sonar-efs-mount-3" {
  file_system_id  = aws_efs_file_system.sonar-efs.id
  subnet_id       = module.vpc.private_subnets[2]
  security_groups = [aws_security_group.efs-sg.id]
}
